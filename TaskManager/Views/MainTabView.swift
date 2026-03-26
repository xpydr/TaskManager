import SwiftUI
import SwiftData

struct MainTabView: View {
    private enum Tab: Hashable {
        case tasks, calendar, profile, completed
    }

    @State private var selectedTab: Tab = .tasks
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

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)

            CompletedView()
                .tabItem {
                    Label("Completed", systemImage: "checkmark")
                }
                .tag(Tab.completed)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) {
            customTabBar
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView()
        }
    }

    private var customTabBar: some View {
        HStack {
            tabItem(icon: "list.bullet", title: "Tasks", tab: .tasks)
            Spacer()
            tabItem(icon: "calendar", title: "Calendar", tab: .calendar)

            Spacer()

            Button {
                showAddTask = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.365, green: 0.592, blue: 0.902))
                        .frame(width: 52, height: 52)

                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .offset(y: -12)
            }
            .buttonStyle(.plain)

            Spacer()
            tabItem(icon: "person", title: "Profile", tab: .profile)
            Spacer()
            tabItem(icon: "checkmark", title: "Completed", tab: .completed)
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(red: 0.87, green: 0.83, blue: 0.76), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.09), radius: 9, y: 2)
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 6)
        .background(Color.clear)
    }

    private func tabItem(icon: String, title: String, tab: Tab) -> some View {
        let isActive = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(isActive ? Color(red: 0.29, green: 0.44, blue: 0.68) : Color(red: 0.61, green: 0.63, blue: 0.68))

                Text(title)
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(isActive ? Color(red: 0.29, green: 0.44, blue: 0.68) : Color(red: 0.56, green: 0.58, blue: 0.62))
            }
        }
        .buttonStyle(.plain)
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

#Preview {
    MainTabView()
        .modelContainer(for: Task.self, inMemory: true)
}
