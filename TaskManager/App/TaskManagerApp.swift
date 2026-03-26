import SwiftUI
import SwiftData

@main
struct TaskManagerApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Task.self)
            seedMockDataIfNeeded(in: modelContainer.mainContext)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }

    private func seedMockDataIfNeeded(in context: ModelContext) {
        var descriptor = FetchDescriptor<Task>()
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return
        }

        let now = Date()
        let calendar = Calendar.current

        let mockTasks: [Task] = [
            Task(
                title: "UI/UX Design",
                category: "Work",
                status: "To Do",
                dueDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now,
                notes: "Finalize dashboard spacing and typography"
            ),
            Task(
                title: "Practice Swift",
                category: "Personal",
                status: "In Progress",
                dueDate: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: now) ?? now,
                notes: "Review SwiftData query and predicates"
            ),
            Task(
                title: "Get Ready For Marathon",
                category: "Personal",
                status: "To Do",
                dueDate: calendar.date(byAdding: .day, value: 1, to: now) ?? now,
                notes: "Plan hydration and 10k warm-up run"
            ),
            Task(
                title: "Medical Appointment",
                category: "Personal",
                status: "To Do",
                dueDate: calendar.date(byAdding: .day, value: 3, to: now) ?? now,
                notes: "Bring lab report copy"
            ),
            Task(
                title: "Book Summer Trip",
                category: "Wishlist",
                status: "To Do",
                dueDate: calendar.date(byAdding: .day, value: 12, to: now) ?? now,
                notes: "Compare flights and hotels"
            ),
            Task(
                title: "Complete Assignments and Tasks",
                category: "Work",
                status: "Done",
                dueDate: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
                notes: "Submitted all pending work"
            ),
            Task(
                title: "Exam Week",
                category: "Work",
                status: "Done",
                dueDate: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                notes: "Prepared summary notes and checklists"
            )
        ]

        mockTasks.forEach { context.insert($0) }
        try? context.save()
    }
}
