import SwiftUI

struct NotesView: View {
    @ObservedObject private var notes = NotesStore.shared
    @State private var mode: NoteMode = .free
    @FocusState private var freeFocused: Bool
    @FocusState private var focusedTodo: UUID?
    private let brown = Color(red: 0.39, green: 0.28, blue: 0.27)
    private let paper = Color(red: 1, green: 0.966, blue: 0.927)

    private enum NoteMode: String, CaseIterable {
        case free = "自由记录"
        case todo = "待办清单"
    }

    var body: some View {
        ZStack {
            paper.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    Text("🧸 小熊便签")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundStyle(brown)
                        .padding(.top, 10)

                    HStack(spacing: 10) {
                        ForEach(NoteMode.allCases, id: \.self) { item in
                            Button {
                                freeFocused = false
                                focusedTodo = nil
                                mode = item
                            } label: {
                                Text(item.rawValue)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(brown)
                                    .padding(.horizontal, 18).padding(.vertical, 9)
                                    .background(mode == item ? Color(red: 1, green: 0.79, blue: 0.81) : .white.opacity(0.85))
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    GeometryReader { proxy in
                        let width = proxy.size.width
                        let height = proxy.size.height
                        Image("memo-paper")
                            .resizable()
                            .frame(width: width, height: height)
                            .accessibilityHidden(true)

                        // The editable region stays away from the illustrated boy on the right.
                        // Its height is larger than the reference lines; long content scrolls.
                        VStack(alignment: .leading, spacing: 4) {
                            if mode == .free {
                                TextEditor(text: $notes.freeText)
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(brown)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .focused($freeFocused)
                                    .accessibilityLabel("自由便签内容")
                            } else {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 7) {
                                        ForEach($notes.todos) { $todo in
                                            HStack(alignment: .top, spacing: 6) {
                                                Button {
                                                    todo.done.toggle()
                                                } label: {
                                                    Image(systemName: todo.done ? "checkmark.square.fill" : "square")
                                                        .foregroundStyle(brown)
                                                        .font(.system(size: 18))
                                                }
                                                .accessibilityLabel(todo.done ? "标记未完成" : "标记完成")
                                                TextField("写下一件小事…", text: $todo.text, axis: .vertical)
                                                    .lineLimit(1...3)
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(brown)
                                                    .strikethrough(todo.done)
                                                    .focused($focusedTodo, equals: todo.id)
                                                Button { notes.deleteTodo(todo.id) } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(brown.opacity(0.45))
                                                }
                                                .accessibilityLabel("删除待办")
                                            }
                                        }
                                        Button {
                                            notes.addTodo()
                                            if let last = notes.todos.last { focusedTodo = last.id }
                                        } label: {
                                            Label("添加一项", systemImage: "plus.circle")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(brown)
                                        }
                                        .padding(.top, 5)
                                    }
                                }
                                .scrollIndicators(.hidden)
                            }
                        }
                        .frame(width: width * 0.53, height: height * 0.47)
                        .position(x: width * 0.37, y: height * 0.52)
                    }
                    .aspectRatio(1.01, contentMode: .fit)
                    .padding(.horizontal, 7)

                    Text("每一件小事，都值得被好好记住 ♡")
                        .font(.system(size: 12))
                        .foregroundStyle(brown.opacity(0.55))
                        .padding(.bottom, 12)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}
