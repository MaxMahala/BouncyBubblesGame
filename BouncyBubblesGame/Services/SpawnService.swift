import SpriteKit

final class SpawnService {
    func countDynamicObjects(in scene: SKScene, categories: [UInt32]) -> Int {
        var count = 0
        scene.enumerateChildNodes(withName: "//") { node, _ in
            if let c = node.physicsBody?.categoryBitMask, categories.contains(c) { count += 1 }
        }
        return count
    }
}
