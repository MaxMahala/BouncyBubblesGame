import SpriteKit
import AVFAudio

final class AudioService {
    private var node: SKAudioNode?
    private var currentFile: String?

    func ensureLoaded(on scene: SKScene, fileNamed: String,
                      startVolume: Float = 1.0,
                      respectSilentSwitch: Bool = false) {

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(respectSilentSwitch ? .ambient : .playback,
                                    mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch { print("Audio session error:", error) }

        if let node, currentFile == fileNamed, node.parent != nil {
            node.run(.changeVolume(to: startVolume, duration: 0.0))
            return
        }

        node?.removeFromParent()
        currentFile = fileNamed

        let n = SKAudioNode(fileNamed: fileNamed)
        n.autoplayLooped = true
        n.isPositional = false
        scene.addChild(n)
        n.run(.changeVolume(to: startVolume, duration: 0.0))
        node = n
    }

    func setMusic(enabled: Bool, on scene: SKScene, ramp: TimeInterval = 0.2) {
        if node == nil || node?.parent == nil {
            ensureLoaded(on: scene, fileNamed: "interstellar.mp3",
                         startVolume: enabled ? 1.0 : 0.0)
        }
        node?.run(.changeVolume(to: enabled ? 1.0 : 0.0, duration: ramp))
    }
}
