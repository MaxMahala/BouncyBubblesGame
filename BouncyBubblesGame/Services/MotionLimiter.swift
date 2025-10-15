import SpriteKit

final class MotionLimiter {
    private let MAX_FALL_DY: CGFloat = 300.0

    private let BALL_MAX_DX: CGFloat  = 40.0
    private let GEM_MAX_DX: CGFloat   = 35.0
    private let MINI_MAX_DX: CGFloat  = 28.0
    private let SHARD_MAX_DX: CGFloat = 22.0

    private let NEARLY_STILL_SPEED: CGFloat = 6.0
    private let NEARLY_STILL_ANG: CGFloat   = 0.1
    private let GROUNDED_GRACE: TimeInterval = 0.20
    private let MAX_IDLE: TimeInterval = 30.0

    private var floorY: CGFloat = 0

    init(cat: Any.Type) {}

    func setFloorY(_ y: CGFloat) { floorY = y }

    func scanAndClamp(in scene: SKScene, now: TimeInterval) {
        scene.enumerateChildNodes(withName: "//") { node, _ in
            guard let body = node.physicsBody else { return }

            if let t = node.userData?["lastTouchT"] as? TimeInterval,
               now - t >= self.MAX_IDLE {
                node.removeFromParent()
                return
            }

            switch body.categoryBitMask {
            case Cat.smallBall:
                self.hClamp(body, limit: self.BALL_MAX_DX)
                self.vClamp(body)
                self.groundedCleanup(node: node, body: body, now: now)

            case Cat.gemSmall:
                self.hClamp(body, limit: self.GEM_MAX_DX)
                self.vClamp(body)
                self.groundedCleanup(node: node, body: body, now: now)

            case Cat.miniBall:
                self.hClamp(body, limit: self.MINI_MAX_DX)
                self.vClamp(body)
                self.groundedCleanup(node: node, body: body, now: now)

            case Cat.shard:
                self.hClamp(body, limit: self.SHARD_MAX_DX)
                self.vClamp(body)
                self.groundedCleanup(node: node, body: body, now: now)

            default: break
            }
        }
    }

    private func hClamp(_ body: SKPhysicsBody, limit: CGFloat) {
        let v = body.velocity
        let clampedDX = max(-limit, min(limit, v.dx))
        if clampedDX != v.dx { body.velocity = CGVector(dx: clampedDX, dy: v.dy) }
    }
    private func vClamp(_ body: SKPhysicsBody) {
        if body.velocity.dy < -MAX_FALL_DY { body.velocity.dy = -MAX_FALL_DY }
    }

    private func nearlyStill(_ body: SKPhysicsBody) -> Bool {
        hypot(body.velocity.dx, body.velocity.dy) < NEARLY_STILL_SPEED &&
        abs(body.angularVelocity) < NEARLY_STILL_ANG
    }
    private func isOnFloor(_ node: SKNode) -> Bool {
        let minY = node.calculateAccumulatedFrame().minY
        return minY <= floorY + 1
    }

    private func groundedCleanup(node: SKNode, body: SKPhysicsBody, now: TimeInterval) {
        let ud = node.userData ?? NSMutableDictionary()
        if isOnFloor(node) && nearlyStill(body) {
            if let t = ud["groundT"] as? TimeInterval {
                if now - t >= GROUNDED_GRACE { node.removeFromParent() }
            } else {
                ud["groundT"] = now
                node.userData = ud
            }
        } else if ud["groundT"] != nil {
            ud.removeObject(forKey: "groundT")
            node.userData = ud
        }
    }
}
