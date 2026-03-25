import SwiftUI
import SwiftData

@main
struct TaskManagerApp: App {
    var body: some Scene {
        WindowGroup {
            TaskListView()
        }
        .modelContainer(for: Task.self)
    }
}
