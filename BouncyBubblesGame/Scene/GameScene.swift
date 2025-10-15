import SpriteKit

final class GameScene: SKScene {
    private(set) var coordinator: GameCoordinator?

    public func setMusic(enabled: Bool) {
        coordinator?.setMusic(enabled: enabled)
    }
    public func setPaused(_ paused: Bool) {
        isPaused = paused
    }

    private var activeTouch: UITouch?
    private var targetX: CGFloat?

    private var didConfigure = false

    public func setCoordinator(_ c: GameCoordinator) {
        coordinator = c
        if view != nil, didConfigure == false {
            coordinator?.configureScene()
            didConfigure = true
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        isUserInteractionEnabled = true
        if didConfigure == false, let c = coordinator {
            c.configureScene()
            didConfigure = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard didConfigure, let c = coordinator else { return }
        c.guardRestartIfGameOver()
        if activeTouch == nil, let t = touches.first {
            activeTouch = t
            targetX = t.location(in: self).x
            c.shoot()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = activeTouch, touches.contains(t) else { return }
        targetX = t.location(in: self).x
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = activeTouch, touches.contains(t) { activeTouch = nil; targetX = nil }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = activeTouch, touches.contains(t) { activeTouch = nil; targetX = nil }
    }

    override func update(_ currentTime: TimeInterval) {
        coordinator?.update(currentTime: currentTime, targetX: targetX)
    }
}
