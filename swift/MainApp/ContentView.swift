import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: TodoStore

    @State private var viewingDate: String = TodoStore.dateKey()
    @State private var newTodoText: String = ""
    @FocusState private var inputFocused: Bool

    private var isToday: Bool { viewingDate == store.todayKey }
    private var todos: [TodoItem] { store.todos(for: viewingDate) }

    private var displayDate: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        guard let date = f.date(from: viewingDate) else { return viewingDate }
        let out = DateFormatter()
        out.dateFormat = "EEE / MMM d"
        out.locale = Locale(identifier: "en_US")
        return out.string(from: date).uppercased()
    }

    var body: some View {
        ZStack {
            Color.todoPink.ignoresSafeArea()

            // Paper grain overlay
            Rectangle()
                .fill(.black.opacity(0.035))
                .blendMode(.multiply)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                titleBarArea
                headerView
                dateNavView
                DashedDivider()
                    .padding(.horizontal, 16)
                    .frame(height: 3)
                todoListView
                addTodoView
            }
        }
        .frame(width: 420, height: 700)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.todoOrange, lineWidth: 2.5)
        )
        .shadow(color: .todoOrangeDark.opacity(0.3), radius: 0, x: 3, y: 3)
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
    }

    // MARK: - Title bar (drag + close/minimize)

    private var titleBarArea: some View {
        HStack {
            HStack(spacing: 6) {
                windowButton(label: "×", action: { NSApp.keyWindow?.close() })
                windowButton(label: "−", action: { NSApp.keyWindow?.miniaturize(nil) })
            }
            Spacer()
        }
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(Color.todoPink)
        .overlay(
            Rectangle()
                .frame(height: 1.5)
                .foregroundColor(.todoOrange.opacity(0.35)),
            alignment: .bottom
        )
    }

    private func windowButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.todoTitle(11))
                .frame(width: 18, height: 18)
                .foregroundColor(.todoOrange)
                .overlay(
                    Circle().stroke(Color.todoOrange, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Rectangle().frame(width: 55, height: 2)
                Rectangle().frame(width: 30, height: 2)
                Rectangle().frame(width: 55, height: 2)
            }
            .foregroundColor(.todoOrange)

            Text("TO-DO-DO")
                .font(.todoTitle(38))
                .foregroundColor(.todoOrange)
                .tracking(4)
                .shadow(color: .todoOrange.opacity(0.22), radius: 0, x: 1.5, y: 1.5)

            HStack(spacing: 4) {
                Rectangle().frame(width: 130, height: 2)
                Rectangle().frame(width: 20, height: 2)
            }
            .foregroundColor(.todoOrange)
        }
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    // MARK: - Date navigation

    private var dateNavView: some View {
        HStack {
            navButton(direction: -1)

            VStack(spacing: 2) {
                Text(displayDate)
                    .font(.todoTitle(15))
                    .foregroundColor(.todoOrange)
                    .tracking(2.5)

                if isToday {
                    Text("TODAY")
                        .font(.todoTitle(9))
                        .tracking(2)
                        .foregroundColor(.todoPink)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 1)
                        .background(Color.todoOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }
            }

            navButton(direction: +1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private func navButton(direction: Int) -> some View {
        let dates   = store.sortedDates
        let idx     = dates.firstIndex(of: viewingDate) ?? dates.count - 1
        let enabled = direction < 0 ? idx > 0 : idx < dates.count - 1

        return Button {
            let newIdx = idx + direction
            if newIdx >= 0 && newIdx < dates.count {
                viewingDate = dates[newIdx]
            }
        } label: {
            Text(direction < 0 ? "‹" : "›")
                .font(.todoTitle(28))
                .frame(width: 36, height: 36)
                .foregroundColor(.todoOrange.opacity(enabled ? 1 : 0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.todoOrange.opacity(enabled ? 1 : 0.3), lineWidth: 2.5)
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    // MARK: - Todo list

    private var todoListView: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                if todos.isEmpty {
                    VStack(spacing: 6) {
                        Text("아직 할 일이 없어요")
                            .font(.todoBody(16))
                            .foregroundColor(.todoOrange.opacity(0.45))
                        Text(isToday ? "아래에 추가해보세요 ↓" : "이 날은 기록이 없어요")
                            .font(.todoBody(13))
                            .foregroundColor(.todoOrange.opacity(0.35))
                    }
                    .padding(.top, 40)
                } else {
                    ForEach(todos) { item in
                        TodoItemRow(
                            item: item,
                            isEditable: isToday,
                            onToggle: {
                                store.toggleDone(item)
                                WidgetCenter.shared.reloadAllTimelines()
                            },
                            onStar: {
                                store.togglePriority(item)
                                WidgetCenter.shared.reloadAllTimelines()
                            },
                            onDelete: {
                                store.delete(item)
                                WidgetCenter.shared.reloadAllTimelines()
                            },
                            onEdit: { newText in
                                store.updateText(item, newText: newText)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Add todo

    private var addTodoView: some View {
        VStack(spacing: 0) {
            DashedDivider()
                .padding(.horizontal, 16)
                .frame(height: 3)

            if isToday {
                HStack(spacing: 8) {
                    TextField("새로운 할 일 추가...", text: $newTodoText)
                        .font(.todoBody(16))
                        .foregroundColor(.todoOrange)
                        .textFieldStyle(.plain)
                        .focused($inputFocused)
                        .onSubmit { submitTodo() }

                    Button(action: submitTodo) {
                        Text("+")
                            .font(.todoTitle(24))
                            .frame(width: 36, height: 36)
                            .foregroundColor(.todoOrange)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.todoOrange, lineWidth: 2.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            } else {
                Text("과거 날짜는 수정할 수 없어요")
                    .font(.todoBody(12))
                    .foregroundColor(.todoOrange.opacity(0.45))
                    .padding(.vertical, 12)
            }
        }
        .padding(.bottom, 4)
    }

    private func submitTodo() {
        store.add(text: newTodoText)
        newTodoText = ""
        WidgetCenter.shared.reloadAllTimelines()
    }
}
