import Foundation

struct TodoItem: Codable, Identifiable, Equatable, Hashable {
    var id: UUID    = UUID()
    var text: String
    var isDone: Bool = false
    var isPriority: Bool = false
    var createdAt: Date = Date()

    init(id: UUID = UUID(), text: String, isDone: Bool = false,
         isPriority: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.isDone = isDone
        self.isPriority = isPriority
        self.createdAt = createdAt
    }
}
