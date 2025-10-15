import SpriteKit
import QuartzCore

final class EntityFactory {
    private let cat: Any.Type
    private let textures = ["red-ball","blue-ball","green-ball","silver-ball"]

    private let SHARD_MAX_DX: CGFloat = 22.0
    private let SHARD_RESTITUTION: CGFloat = 0.80
    private let SHARD_LINEAR_DAMPING: CGFloat = 0.14
    private let SHARD_ANGULAR_DAMPING: CGFloat = 0.16
    private let MAX_FALL_DY: CGFloat = 100.0

    init(cat: Any.Type) { self.cat = cat }

    func makeSprite(named: String, targetWidth: CGFloat) -> SKSpriteNode {
        let n = SKSpriteNode(imageNamed: named)
        let scale = targetWidth / n.size.width
        n.setScale(scale)
        return n
    }
    func physicsSize(for s: SKSpriteNode) -> CGSize {
        CGSize(width: s.size.width * s.xScale, height: s.size.height * s.yScale)
    }
    func physicsCircleRadius(for s: SKSpriteNode) -> CGFloat {
        (s.size.width * s.xScale) * 0.5
    }

    func addBackground(named: String, in scene: SKScene) {
        let bg = SKSpriteNode(imageNamed: named)
        bg.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        bg.size = scene.frame.size
        bg.zPosition = -10
        scene.addChild(bg)
    }

    func addWorldEdges(in scene: SKScene, category: UInt32) {
        scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
        scene.physicsBody?.categoryBitMask = category
    }

    func addFloor(in scene: SKScene, yOffset: CGFloat, category: UInt32, restitution: CGFloat) {
        let y = scene.frame.minY + yOffset
        let floor = SKNode()
        floor.name = "floor"
        floor.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: scene.frame.minX, y: y),
                                          to: CGPoint(x: scene.frame.maxX, y: y))
        floor.physicsBody?.restitution = restitution
        floor.physicsBody?.categoryBitMask = category
        scene.addChild(floor)
    }

    func addPlayer(in scene: SKScene, category: UInt32, contact: [UInt32]) {
        let p = makeSprite(named: "player-astro", targetWidth: 60)
        p.name = "player"
        p.position = CGPoint(x: scene.frame.midX, y: scene.frame.minY + 70)
        p.zPosition = 1

        let base = physicsSize(for: p)
        let inflated = CGSize(width: base.width * 1.15, height: base.height * 1.15)
        let body = SKPhysicsBody(rectangleOf: inflated)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = category
        body.contactTestBitMask = contact.reduce(0, |)
        body.collisionBitMask = 0
        p.physicsBody = body

        scene.addChild(p)
    }

    func playerNode(in scene: SKScene) -> SKSpriteNode? {
        scene.childNode(withName: "player") as? SKSpriteNode
    }

    private func tagSpawn(_ n: SKNode) {
        let ud = n.userData ?? NSMutableDictionary()
        ud["lastTouchT"] = CACurrentMediaTime()
        n.userData = ud
    }
    func refreshLastTouch(_ n: SKNode) {
        let ud = n.userData ?? NSMutableDictionary()
        ud["lastTouchT"] = CACurrentMediaTime()
        n.userData = ud
    }

    func spawnBall80(in scene: SKScene, cat: UInt32) {
        let tex = textures.randomElement()!
        let n = makeSprite(named: tex, targetWidth: 80)
        n.position = CGPoint(x: CGFloat.random(in: scene.frame.minX + 40 ... scene.frame.maxX - 40),
                             y: scene.frame.maxY - 40)
        n.zPosition = 1

        let b = SKPhysicsBody(circleOfRadius: physicsCircleRadius(for: n))
        b.restitution = 0.93
        b.friction = 0
        b.linearDamping = 0.07
        b.angularDamping = 0.07
        b.categoryBitMask = cat
        b.contactTestBitMask = Cat.player | Cat.bullet | Cat.world
        b.collisionBitMask = Cat.world | Cat.smallBall | Cat.shard | Cat.miniBall | Cat.gemSmall
        b.usesPreciseCollisionDetection = true
        n.physicsBody = b

        n.userData = ["canSplit": true, "tex": tex, "kind": "ball"]
        scene.addChild(n)
        tagSpawn(n)
        n.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -40...40), dy: 0)
    }

    func spawnGem80(in scene: SKScene, cat: UInt32) {
        let n = makeSprite(named: "gem-1", targetWidth: 80)
        n.position = CGPoint(x: CGFloat.random(in: scene.frame.minX + 40 ... scene.frame.maxX - 40),
                             y: scene.frame.maxY - 40)
        n.zPosition = 1

        let b = SKPhysicsBody(texture: n.texture!, size: physicsSize(for: n))
        b.restitution = 0.93
        b.friction = 0
        b.linearDamping = 0.09
        b.angularDamping = 0.10
        b.categoryBitMask = cat
        b.contactTestBitMask = Cat.player | Cat.bullet | Cat.world
        b.collisionBitMask = Cat.world | Cat.gemSmall | Cat.shard | Cat.miniBall | Cat.smallBall
        b.usesPreciseCollisionDetection = true
        n.physicsBody = b

        n.userData = ["canSplit": true, "tex": "gem-2", "kind": "gem"]
        scene.addChild(n)
        tagSpawn(n)
        n.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -35...35), dy: 0)
    }

    func spawnMini40(in scene: SKScene, cat: UInt32) {
        let tex = textures.randomElement()!
        let n = makeSprite(named: tex, targetWidth: 40)
        n.position = CGPoint(x: CGFloat.random(in: scene.frame.minX + 40 ... scene.frame.maxX - 40),
                             y: scene.frame.maxY - 40)
        n.zPosition = 1

        let b = SKPhysicsBody(circleOfRadius: physicsCircleRadius(for: n))
        b.restitution = 0.96
        b.friction = 0
        b.linearDamping = 0.09
        b.angularDamping = 0.09
        b.categoryBitMask = cat
        b.contactTestBitMask = Cat.player | Cat.bullet | Cat.world
        b.collisionBitMask = Cat.world | Cat.miniBall | Cat.smallBall | Cat.gemSmall | Cat.shard
        b.usesPreciseCollisionDetection = true
        n.physicsBody = b

        n.userData = ["canSplit": false, "tex": tex, "kind": "mini"]
        scene.addChild(n)
        tagSpawn(n)
        n.physicsBody?.velocity = CGVector(dx: CGFloat.random(in: -30...30), dy: 0)
    }

    func spawnShardPair(from parent: SKSpriteNode, in scene: SKScene) {
        let parentVel = parent.physicsBody?.velocity ?? .zero
        let texName: String = {
            if let k = parent.userData?["kind"] as? String, k == "gem" {
                return (parent.userData?["tex"] as? String) ?? "gem-2"
            } else {
                return (parent.userData?["tex"] as? String) ?? textures.randomElement()!
            }
        }()

        for dir in [-1, 1] {
            let shard = makeSprite(named: texName, targetWidth: 40)
            shard.position = parent.position
            shard.zPosition = 1

            let body: SKPhysicsBody = texName.hasPrefix("gem")
            ? SKPhysicsBody(texture: shard.texture!, size: physicsSize(for: shard))
            : SKPhysicsBody(circleOfRadius: physicsCircleRadius(for: shard))

            body.restitution = SHARD_RESTITUTION
            body.friction = 0
            body.linearDamping = SHARD_LINEAR_DAMPING
            body.angularDamping = SHARD_ANGULAR_DAMPING
            body.categoryBitMask = Cat.shard
            body.contactTestBitMask = Cat.player | Cat.bullet | Cat.world
            body.collisionBitMask = Cat.world | Cat.shard | Cat.smallBall | Cat.gemSmall | Cat.miniBall
            body.usesPreciseCollisionDetection = true
            shard.physicsBody = body

            shard.userData = ["canSplit": false, "kind": "shard"]
            scene.addChild(shard)
            tagSpawn(shard)

            let baseDX = parentVel.dx * 0.5 + CGFloat(dir) * 18.0
            let baseDY = max(parentVel.dy * 0.5, 0) + 50.0
            shard.physicsBody?.velocity = CGVector(dx: baseDX, dy: baseDY)

            if let b = shard.physicsBody {
                b.velocity.dx = max(-SHARD_MAX_DX, min(SHARD_MAX_DX, b.velocity.dx))
                if b.velocity.dy < -MAX_FALL_DY { b.velocity.dy = -MAX_FALL_DY }
            }
        }
    }

    func spawnBullet(in scene: SKScene,
                     at origin: CGPoint,
                     bulletCategory: UInt32,
                     hitCategories: [UInt32],
                     speed: CGFloat) {
        let bullet = makeSprite(named: "bullet", targetWidth: 40)
        bullet.name = "bullet"
        bullet.position = origin
        bullet.zPosition = 1

        let body = SKPhysicsBody(rectangleOf: physicsSize(for: bullet))
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = bulletCategory
        body.contactTestBitMask = hitCategories.reduce(0, |)
        body.collisionBitMask = 0
        body.usesPreciseCollisionDetection = true
        bullet.physicsBody = body

        scene.addChild(bullet)
        bullet.physicsBody?.velocity = CGVector(dx: 0, dy: speed)
        bullet.run(.sequence([.wait(forDuration: 2.0), .removeFromParent()]))
    }

    func showGameOverPopup(in scene: SKScene) {
        let overlay = SKSpriteNode(color: .black.withAlphaComponent(0.6), size: scene.frame.size)
        overlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        overlay.zPosition = 10
        overlay.name = "gameover"
        scene.addChild(overlay)

        let title = SKLabelNode(fontNamed: "Avenir-Heavy")
        title.text = "GAME OVER"
        title.fontSize = 36
        title.position = CGPoint(x: 0, y: 20)
        overlay.addChild(title)

        let btn = SKLabelNode(fontNamed: "Avenir-Book")
        btn.text = "Tap to Restart"
        btn.fontSize = 20
        btn.position = CGPoint(x: 0, y: -30)
        overlay.addChild(btn)
    }
}
