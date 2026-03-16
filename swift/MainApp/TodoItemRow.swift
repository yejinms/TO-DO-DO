import SwiftUI

struct TodoItemRow: View {
    let item: TodoItem
    let isEditable: Bool
    let onToggle: () -> Void
    let onStar: () -> Void
    let onDelete: () -> Void
    let onEdit: (String) -> Void

    @State private var isEditing = false
    @State private var editText  = ""
    @State private var isHovered = false
    @FocusState private var editFocused: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 8) {

            // ── Checkbox ──────────────────────────────────
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.todoOrange, lineWidth: 2.5)
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(-0.8))

                    if item.isDone {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.todoOrange)
                            .frame(width: 20, height: 20)

                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.todoPink)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 3)

            // ── Text / Inline edit ─────────────────────────
            Group {
                if isEditing {
                    TextField("", text: $editText)
                        .font(.todoBody(17))
                        .foregroundColor(.todoOrange)
                        .textFieldStyle(.plain)
                        .focused($editFocused)
                        .onSubmit { commitEdit() }
                        .onExitCommand { cancelEdit() }
                        .overlay(
                            Rectangle()
                                .frame(height: 1.5)
                                .foregroundColor(.todoOrange.opacity(0.4))
                                .offset(y: 14),
                            alignment: .bottom
                        )
                } else {
                    Text(item.text)
                        .font(.todoBody(17))
                        .foregroundColor(item.isDone
                            ? .todoOrange.opacity(0.45)
                            : .todoOrange)
                        .strikethrough(item.isDone, color: .todoOrange)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture(count: 2) {
                            guard isEditable else { return }
                            editText = item.text
                            isEditing = true
                            editFocused = true
                        }
                }
            }

            // ── Star ──────────────────────────────────────
            Button(action: onStar) {
                Text(item.isPriority ? "★" : "☆")
                    .font(.system(size: 17))
                    .foregroundColor(.todoOrange.opacity(item.isPriority ? 1 : 0.3))
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            // ── Delete (hover) ────────────────────────────
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.todoOrange.opacity(0.5))
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
            .padding(.top, 3)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(item.isPriority ? Color.todoWhite : Color.todoPinkLight)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay(
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.todoOrange, lineWidth: item.isPriority ? 2.5 : 2)
        )
        .shadow(color: .todoOrange.opacity(0.2), radius: 0, x: 1.5, y: 1.5)
        .opacity(isEditable ? 1 : 0.72)
        .onHover { isHovered = $0 }
    }

    private func commitEdit() {
        isEditing = false
        onEdit(editText)
    }

    private func cancelEdit() {
        isEditing = false
    }
}
