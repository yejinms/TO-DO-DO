import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct TodoEntry: TimelineEntry {
    let date: Date
    let todos: [TodoItem]
    let dateKey: String
}

// MARK: - Timeline Provider

struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), todos: sampleTodos, dateKey: TodoStore.dateKey())
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        let entry = makeEntry()
        // 자정에 새 날짜로 갱신
        let midnight = Calendar.current.nextDate(
            after: Date(),
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        )!
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }

    private func makeEntry() -> TodoEntry {
        let store = TodoStore()
        let key   = TodoStore.dateKey()
        return TodoEntry(date: Date(), todos: store.todos(for: key), dateKey: key)
    }

    private var sampleTodos: [TodoItem] {
        [
            TodoItem(text: "커피 한 잔 마시기", isPriority: true),
            TodoItem(text: "운동 30분"),
            TodoItem(text: "코드 리뷰", isDone: true),
        ]
    }
}

// MARK: - Widget Entry View

struct TodoWidgetEntryView: View {
    let entry: TodoEntry
    @Environment(\.widgetFamily) var family

    private var visibleTodos: [TodoItem] {
        let limit: Int
        switch family {
        case .systemSmall:  limit = 4
        case .systemMedium: limit = 6
        default:            limit = 10
        }
        return Array(entry.todos.prefix(limit))
    }

    private var displayDate: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: entry.dateKey) else { return entry.dateKey }
        let out = DateFormatter()
        out.dateFormat = "EEE / MMM d"
        out.locale = Locale(identifier: "en_US")
        return out.string(from: date).uppercased()
    }

    private var titleSize: CGFloat { family == .systemSmall ? 18 : 22 }

    var body: some View {
        ZStack {
            Color.todoPink

            // grain
            Rectangle()
                .fill(.black.opacity(0.03))
                .blendMode(.multiply)

            VStack(alignment: .leading, spacing: 6) {

                // ── Header ───────────────────────────────
                VStack(spacing: 2) {
                    Text("TO-DO-DO")
                        .font(.todoTitle(titleSize))
                        .foregroundColor(.todoOrange)
                        .tracking(2)

                    Text(displayDate)
                        .font(.todoTitle(9))
                        .foregroundColor(.todoOrange)
                        .tracking(1.5)
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color.todoOrange.opacity(0.5))
                    .frame(height: 1.5)

                // ── Todo items ───────────────────────────
                if visibleTodos.isEmpty {
                    Spacer()
                    Text("오늘의 할 일을 추가해보세요")
                        .font(.todoBody(12))
                        .foregroundColor(.todoOrange.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                } else {
                    ForEach(visibleTodos) { item in
                        HStack(spacing: 6) {
                            Image(systemName: item.isDone
                                  ? "checkmark.square.fill" : "square")
                                .font(.system(size: 12))
                                .foregroundColor(.todoOrange.opacity(item.isDone ? 0.45 : 1))

                            Text(item.text)
                                .font(.todoBody(family == .systemSmall ? 13 : 14))
                                .foregroundColor(.todoOrange.opacity(item.isDone ? 0.4 : 1))
                                .strikethrough(item.isDone, color: .todoOrange)
                                .lineLimit(1)

                            Spacer()

                            if item.isPriority {
                                Text("★")
                                    .font(.system(size: 10))
                                    .foregroundColor(.todoOrange)
                            }
                        }
                    }

                    Spacer()

                    if entry.todos.count > visibleTodos.count {
                        Text("+\(entry.todos.count - visibleTodos.count)개 더")
                            .font(.todoTitle(9))
                            .foregroundColor(.todoOrange.opacity(0.5))
                    }
                }
            }
            .padding(12)
        }
        .containerBackground(Color.todoPink, for: .widget)
    }
}

// MARK: - Widget Definition

@main
struct TO_DO_DOWidget: Widget {
    let kind = "TO_DO_DOWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("TO-DO-DO")
        .description("오늘의 할 일 목록")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
