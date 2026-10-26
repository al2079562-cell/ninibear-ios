import Foundation
import Combine

struct NiniTodo: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var text: String = ""
    var done: Bool = false
}

final class NotesStore: ObservableObject {
    static let shared = NotesStore()
    @Published var freeText: String { didSet { defaults.set(freeText, forKey: "nini_notes_free_v1") } }
    @Published var todos: [NiniTodo] { didSet { saveTodos() } }
    private let defaults = UserDefaults.standard

    private init() {
        freeText = defaults.string(forKey: "nini_notes_free_v1") ?? ""
        if let data = defaults.data(forKey: "nini_notes_todos_v1"),
           let saved = try? JSONDecoder().decode([NiniTodo].self, from: data) {
            todos = saved
        } else { todos = [] }
    }
    private func saveTodos() {
        if let data = try? JSONEncoder().encode(todos) {
            defaults.set(data, forKey: "nini_notes_todos_v1")
        }
    }
    func addTodo() { todos.append(NiniTodo()) }
    func deleteTodo(_ id: UUID) { todos.removeAll { $0.id == id } }
}
