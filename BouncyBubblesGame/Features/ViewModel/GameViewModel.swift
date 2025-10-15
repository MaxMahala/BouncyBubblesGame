import SwiftUI
import SpriteKit

final class GameViewModel: ObservableObject, GameCoordinatorDelegate {
    @Published var isPaused = false { didSet { coordinator?.setPaused(isPaused) } }
    @Published var musicOn  = true  { didSet { coordinator?.setMusic(enabled: musicOn) } }
    @Published var isLoading = true

    @Published private(set) var score: Int = 0

    private(set) weak var scene: GameScene?
    private var coordinator: GameCoordinator?

    func attach(scene: GameScene) {
        self.scene = scene
        if coordinator == nil {
            let c = GameCoordinator(scene: scene)
            c.delegate = self
            coordinator = c
            scene.setCoordinator(c)
        }
        coordinator?.configureScene()
        coordinator?.setMusic(enabled: musicOn)
        coordinator?.setPaused(isPaused)
    }
    
    func startLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.isLoading = false
            }
        }
    }

    func togglePause() {
        isPaused.toggle()
    }
    
    func toggleMusic() {
        musicOn.toggle()
    }

    func scoreDidChange(_ score: Int) {
        if Thread.isMainThread { self.score = score }
        else { DispatchQueue.main.async { self.score = score } }
    }
}
