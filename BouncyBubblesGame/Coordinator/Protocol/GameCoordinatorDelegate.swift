import Foundation

protocol GameCoordinatorDelegate: AnyObject {
    func scoreDidChange(_ score: Int)
}
