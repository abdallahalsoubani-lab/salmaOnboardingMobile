import Foundation

protocol StorageServiceProtocol {
    func save<T: Codable>(_ value: T, forKey key: String)
    func load<T: Codable>(forKey key: String) -> T?
    func remove(forKey key: String)
    func getString(forKey key: String) -> String?
    func setString(_ value: String, forKey key: String)
}
