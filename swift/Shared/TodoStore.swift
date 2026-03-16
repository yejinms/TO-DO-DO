import Foundation

let kAppGroupID = "group.com.yejinms.tododo"
let kStorageKey = "todos_v1"

class TodoStore: ObservableObject {
    static let shared = TodoStore()

    @Published var allTodos: [String: [TodoItem]] = [:]

    private var defaults: UserDefaults {
        UserDefaults(suiteName: kAppGroupID) ?? .standard
    }

    init() { load() }

    // MARK: - Date helpers

    static func dateKey(for date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    var todayKey: String { TodoStore.dateKey() }

    var sortedDates: [String] {
        var dates = Array(allTodos.keys)
        if !dates.contains(todayKey) { dates.append(todayKey) }
        return dates.sorted()
    }

    // MARK: - Read

    func todos(for dateKey: String) -> [TodoItem] {
        allTodos[dateKey] ?? []
    }

    // MARK: - Write (today only)

    func add(text: String) {
        let text = text.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        mutate(key: todayKey) { $0.append(TodoItem(text: text)) }
    }

    func toggleDone(_ item: TodoItem) {
        mutate(key: todayKey) { list in
            guard let i = list.firstIndex(where: { $0.id == item.id }) else { return }
            list[i].isDone.toggle()
        }
    }

    func togglePriority(_ item: TodoItem) {
        mutate(key: todayKey) { list in
            guard let i = list.firstIndex(where: { $0.id == item.id }) else { return }
            list[i].isPriority.toggle()
            list = TodoStore.sorted(list)
        }
    }

    func delete(_ item: TodoItem) {
        mutate(key: todayKey) { $0.removeAll { $0.id == item.id } }
    }

    func updateText(_ item: TodoItem, newText: String) {
        let newText = newText.trimmingCharacters(in: .whitespaces)
        if newText.isEmpty { delete(item); return }
        mutate(key: todayKey) { list in
            guard let i = list.firstIndex(where: { $0.id == item.id }) else { return }
            list[i].text = newText
        }
    }

    // MARK: - Internals

    private func mutate(key: String, transform: (inout [TodoItem]) -> Void) {
        var list = todos(for: key)
        transform(&list)
        allTodos[key] = list.isEmpty ? nil : list
        save()
    }

    static func sorted(_ list: [TodoItem]) -> [TodoItem] {
        list.sorted {
            if $0.isPriority != $1.isPriority { return $0.isPriority }
            return $0.createdAt < $1.createdAt
        }
    }

    // MARK: - Persistence

    func load() {
        guard
            let data    = defaults.data(forKey: kStorageKey),
            let decoded = try? JSONDecoder().decode([String: [TodoItem]].self, from: data)
        else { return }
        allTodos = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(allTodos) else { return }
        defaults.set(data, forKey: kStorageKey)
        defaults.synchronize()
    }
}
