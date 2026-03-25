import SwiftUI
import SwiftData

struct MainTabView: View {
    private enum Tab: Hashable {
        case tasks, calendar, create, profile, completed
    }

    @State private var selectedTab: Tab = .tasks
    @State private var previousTab: Tab = .tasks
    @State private var showAddTask: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
                .tag(Tab.tasks)

            CalendarPlaceholderView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(Tab.calendar)

            // Create tab behaves like an action button
            Color.clear
                .tabItem {
                    Label("", systemImage: "plus.circle")
                }
                .tag(Tab.create)

            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)

            CompletedTasksView()
                .tabItem {
                    Label("Completed", systemImage: "checkmark")
                }
                .tag(Tab.completed)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .create {
                showAddTask = true
                // Immediately revert to the last real tab so tab bar remains on a page
                selectedTab = previousTab
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
        }
    }
}

private struct CalendarPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Calendar",
                systemImage: "calendar",
                description: Text("Calendar view coming soon.")
            )
            .navigationTitle("Calendar")
        }
    }
}

private struct ProfilePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Profile",
                systemImage: "person",
                description: Text("Profile view coming soon.")
            )
            .navigationTitle("Profile")
        }
    }
}

struct CompletedTasksView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<Task> { $0.status == "Done" },
        sort: \Task.createdAt,
        order: .reverse
    )
    private var completedTasks: [Task]

    var body: some View {
        NavigationStack {
            Group {
                if completedTasks.isEmpty {
                    ContentUnavailableView(
                        "No completed tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Tasks you mark as Done will appear here.")
                    )
                } else {
                    List {
                        ForEach(completedTasks) { task in
                            TaskRowView(task: task)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Completed")
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedTasks[index])
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Task.self, inMemory: true)
}
