import SpriteKit

final class GameCoordinator: NSObject, SKPhysicsContactDelegate {
    let BASE_SIZE: CGFloat = 80
    var SHARD_SIZE: CGFloat { BASE_SIZE / 2 }
    let MINI_SIZE: CGFloat = 40

    private let playerSpeed: CGFloat = 360
    private let shootCooldown: TimeInterval = 0.22
    private let bulletSpeed: CGFloat = 700

    private var spawnInterval: TimeInterval = 7.0
    private let spawnMin: TimeInterval = 3.8
    private let spawnAccel: Double = 0.995
    private let spawnJitter: TimeInterval = 0.60
    private var nextSpawnAt: TimeInterval = 0
    private let MAX_OBJECTS = 1

    private unowned let scene: SKScene
    private let audio: AudioService
    private let entities: EntityFactory
    private let motion: MotionLimiter
    private let spawner: SpawnService

    private var canShoot = true
    private var gameOver = false
    private(set) var isConfigured = false

    weak var delegate: GameCoordinatorDelegate?

    private(set) var score: Int = 0 {
        didSet { delegate?.scoreDidChange(score) }
    }
    private func addPoints(_ p: Int = 1) { score += p }
    private func resetScore() { score = 0 }

    init(scene: SKScene) {
        self.scene = scene
        self.entities = EntityFactory(cat: Cat.self)
        self.motion = MotionLimiter(cat: Cat.self)
        self.audio = AudioService()
        self.spawner = SpawnService()
        super.init()
    }

    func setMusic(enabled: Bool) { audio.setMusic(enabled: enabled, on: scene) }
    func setPaused(_ paused: Bool) { scene.isPaused = paused }

    func configureScene(forceRebuild: Bool = false) {
        if isConfigured && !forceRebuild { return }

        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -3.2)
        scene.physicsWorld.contactDelegate = self

        entities.addBackground(named: "space", in: scene)
        entities.addWorldEdges(in: scene, category: Cat.world)

        let yOffset: CGFloat = 40
        let floorY = scene.frame.minY + yOffset
        entities.addFloor(in: scene, yOffset: yOffset, category: Cat.world, restitution: 0.90)
        motion.setFloorY(floorY)

        entities.addPlayer(in: scene,
                           category: Cat.player,
                           contact: [Cat.smallBall, Cat.gemSmall, Cat.shard, Cat.miniBall])

        audio.ensureLoaded(on: scene, fileNamed: "interstellar.mp3")

        nextSpawnAt = 0
        resetScore()

        canShoot = true
        gameOver = false

        isConfigured = true
    }

    func update(currentTime: TimeInterval, targetX: CGFloat?) {
        guard !gameOver else { return }

        if let x = targetX, let player = entities.playerNode(in: scene) {
            let dt: CGFloat = 1.0 / 60.0
            let dir = x - player.position.x
            let step = max(-playerSpeed, min(playerSpeed, dir / dt)) * dt
            let minX = scene.frame.minX + 40
            let maxX = scene.frame.maxX - 40
            player.position.x = min(max(player.position.x + step, minX), maxX)
        }

        motion.scanAndClamp(in: scene, now: CACurrentMediaTime())

        if nextSpawnAt == 0 {
            scheduleNextSpawn(from: CACurrentMediaTime())
        } else if CACurrentMediaTime() >= nextSpawnAt {
            if currentObjectsCount(in: scene) < MAX_OBJECTS {
                spawnOne()
            }
            scheduleNextSpawn(from: CACurrentMediaTime())
        }
    }

    func shoot() {
        guard isConfigured else { return }
        guard canShoot, !gameOver else { return }
        canShoot = false

        guard let player = entities.playerNode(in: scene) else { return }
        let origin = CGPoint(x: player.position.x, y: player.position.y + 40)

        entities.spawnBullet(in: scene,
                             at: origin,
                             bulletCategory: Cat.bullet,
                             hitCategories: [Cat.smallBall, Cat.gemSmall, Cat.shard, Cat.miniBall],
                             speed: bulletSpeed)

        scene.run(.sequence([.wait(forDuration: shootCooldown),
                             .run { [weak self] in self?.canShoot = true }]))
    }

    func guardRestartIfGameOver() {
        if gameOver { restart() }
    }

    private func currentObjectsCount(in scene: SKScene) -> Int {
        spawner.countDynamicObjects(in: scene,
                                    categories: [Cat.smallBall, Cat.gemSmall, Cat.shard, Cat.miniBall])
    }

    private func scheduleNextSpawn(from now: TimeInterval) {
        let jitter = Double.random(in: -spawnJitter...spawnJitter)
        nextSpawnAt = now + max(spawnMin, spawnInterval + jitter)
        spawnInterval = max(spawnMin, spawnInterval * spawnAccel)
    }

    private func spawnOne() {
        let r = Int.random(in: 0..<10)
        if r < 3 { entities.spawnGem80(in: scene, cat: Cat.gemSmall) }
        else if r < 7 { entities.spawnBall80(in: scene, cat: Cat.smallBall) }
        else { entities.spawnMini40(in: scene, cat: Cat.miniBall) }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA, b = contact.bodyB
        let cats = [a.categoryBitMask, b.categoryBitMask]

        func node(for category: UInt32) -> SKNode? {
            if a.categoryBitMask == category { return a.node }
            if b.categoryBitMask == category { return b.node }
            return nil
        }

        if let na = a.node { entities.refreshLastTouch(na) }
        if let nb = b.node { entities.refreshLastTouch(nb) }

        if cats.contains(Cat.world) {
            let dynamicBody = (a.categoryBitMask == Cat.world) ? b : a
            if let pb = dynamicBody.node?.physicsBody, pb.velocity.dy < -120 {
                let boost = max(abs(pb.velocity.dy) * 0.95, 300)
                pb.velocity.dy = boost
            }
        }

        if cats.contains(Cat.player) &&
           (cats.contains(Cat.smallBall) || cats.contains(Cat.gemSmall) ||
            cats.contains(Cat.shard) || cats.contains(Cat.miniBall)) {
            showGameOver(); return
        }

        if cats.contains(Cat.bullet) &&
           (cats.contains(Cat.smallBall) || cats.contains(Cat.gemSmall) ||
            cats.contains(Cat.shard) || cats.contains(Cat.miniBall)) {

            node(for: Cat.bullet)?.removeFromParent()

            if let bigBall = node(for: Cat.smallBall) as? SKSpriteNode {
                if (bigBall.userData?["canSplit"] as? Bool) == true {
                    bigBall.removeFromParent()
                    entities.spawnShardPair(from: bigBall, in: scene)
                    addPoints(1)
                } else { bigBall.removeFromParent(); addPoints(1) }
                return
            }
            if let bigGem = node(for: Cat.gemSmall) as? SKSpriteNode {
                if (bigGem.userData?["canSplit"] as? Bool) == true {
                    bigGem.removeFromParent()
                    entities.spawnShardPair(from: bigGem, in: scene)
                    addPoints(1)
                } else { bigGem.removeFromParent(); addPoints(1) }
                return
            }
            if let mini = node(for: Cat.miniBall) { mini.removeFromParent(); addPoints(1); return }
            if let shard = node(for: Cat.shard)    { shard.removeFromParent(); addPoints(1); return }
        }
    }

    private func showGameOver() {
        guard !gameOver else { return }
        gameOver = true
        scene.removeAllActions()
        scene.physicsWorld.speed = 0
        entities.showGameOverPopup(in: scene)
    }


    private func restart() {
        scene.removeAllChildren()
        scene.physicsWorld.speed = 1

        spawnInterval = 7.0
        nextSpawnAt = 0
        resetScore()

        canShoot = true
        gameOver = false
        isConfigured = false

        configureScene(forceRebuild: true)
    }
}
