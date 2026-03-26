import SwiftData
import SwiftUI

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var tasks: [Task]

    @State private var searchText: String = ""
    @State private var selectedFilter: TaskFilter = .all

    init() {}

    private let backgroundColor = Color(red: 1.0, green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86, blue: 0.93)
    private let shellBorderColor = Color(red: 0.93, green: 0.91, blue: 0.86)
    private let primaryBlue = Color(red: 0.18, green: 0.39, blue: 0.70)
    private let softBlue = Color(red: 0.84, green: 0.91, blue: 1.00)
    private let textGray = Color(red: 0.42, green: 0.42, blue: 0.42)

    var body: some View {
        GeometryReader { geometry in
            let metrics = LayoutMetrics(width: geometry.size.width)

            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            profileHeader(metrics: metrics)
                            searchBar(metrics: metrics)
                            filterBar(metrics: metrics)

                            Divider()
                                .background(Color(red: 0.75, green: 0.82, blue: 0.94))
                                .padding(.top, 9)

                            sectionView(title: "Today", tasks: todayTasks, metrics: metrics)
                            weekSection(metrics: metrics)
                            completedSection(metrics: metrics)
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 8)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(shellBorderColor)
                        .frame(width: 1)
                }
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(shellBorderColor)
                        .frame(width: 1)
                }
                .safeAreaInset(edge: .bottom) {
                    bottomBar
                        .padding(.horizontal, 8)
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                        .background(Color.clear)
                }
            }
        }
    }

    private var filteredTasks: [Task] {
        tasks.filter { task in
            let matchesFilter: Bool
            switch selectedFilter {
            case .all:
                matchesFilter = true
            case .work:
                matchesFilter = task.category.caseInsensitiveCompare("Work") == .orderedSame
            case .personal:
                matchesFilter = task.category.caseInsensitiveCompare("Personal") == .orderedSame
            case .wishlist:
                matchesFilter = task.category.caseInsensitiveCompare("Wishlist") == .orderedSame
            }

            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let matchesSearch = query.isEmpty
                || task.title.localizedCaseInsensitiveContains(query)
                || task.category.localizedCaseInsensitiveContains(query)

            return matchesFilter && matchesSearch
        }
    }

    private var incompleteTasks: [Task] {
        filteredTasks.filter { $0.status != "Done" }
    }

    private var todayTasks: [Task] {
        incompleteTasks.filter { task in
            guard let due = task.dueDate else { return false }
            return Calendar.current.isDateInToday(due)
        }
    }

    private var upcomingTasks: [Task] {
        incompleteTasks
            .filter { task in
                guard let due = task.dueDate else { return false }
                return !Calendar.current.isDateInToday(due)
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var completedTasks: [Task] {
        filteredTasks
            .filter { $0.status == "Done" }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private func profileHeader(metrics: LayoutMetrics) -> some View {
        HStack(spacing: 9) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.38, green: 0.67, blue: 1.0),
                            Color(red: 0.16, green: 0.33, blue: 0.67)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 42, height: 42)
                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.12, green: 0.31, blue: 0.57))
                            .frame(width: 14, height: 14)
                            .offset(y: -6)

                        Capsule()
                            .fill(Color(red: 0.12, green: 0.31, blue: 0.57))
                            .frame(width: 26, height: 13)
                            .offset(y: 9)
                    }
                )

            Text("User Name")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(Color(red: 0.12, green: 0.31, blue: 0.57))

            Spacer()
        }
        .padding(.horizontal, 8)
    }

    private func searchBar(metrics: LayoutMetrics) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color.gray)
                .font(.system(size: 12, weight: .medium))

            TextField("Search...", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.38, green: 0.44, blue: 0.54))
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(outlineColor, lineWidth: 1)
        )
        .padding(.top, 12)
        .padding(.horizontal, 8)
    }

    private func filterBar(metrics: LayoutMetrics) -> some View {
        HStack(spacing: 7) {
            ForEach(TaskFilter.allCases) { filter in
                Button {
                    selectedFilter = filter
                } label: {
                    Text(filter.title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(selectedFilter == filter ? .white : Color(red: 0.49, green: 0.53, blue: 0.59))
                        .padding(.horizontal, 13)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(selectedFilter == filter ? Color(red: 0.18, green: 0.37, blue: 0.62) : Color(red: 0.74, green: 0.84, blue: 0.98))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.72, green: 0.81, blue: 0.94), lineWidth: selectedFilter == filter ? 0 : 1)
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.top, 14)
        .padding(.horizontal, 8)
    }

    private func sectionView(title: String, tasks: [Task], metrics: LayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(textGray)

            VStack(spacing: 6) {
                if tasks.isEmpty {
                    Text("No tasks")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                } else {
                    ForEach(tasks) { task in
                        TaskCardRow(task: task, isCompletedStyle: false)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.35))
                    .shadow(color: .black.opacity(0.03), radius: 7, y: 2)
            )
        }
    }

    private func weekSection(metrics: LayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("This Week")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(textGray)

                Spacer()

                Text("See All")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.56, green: 0.58, blue: 0.60))
            }

            VStack(spacing: 6) {
                if upcomingTasks.isEmpty {
                    Text("No tasks")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                } else {
                    ForEach(upcomingTasks) { task in
                        TaskCardRow(task: task, isCompletedStyle: false)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.35))
                    .shadow(color: .black.opacity(0.03), radius: 7, y: 2)
            )
        }
    }

    private func completedSection(metrics: LayoutMetrics) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Completed")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(textGray)

                Spacer()

                Text("See All")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.56, green: 0.58, blue: 0.60))
            }

            VStack(spacing: 6) {
                if completedTasks.isEmpty {
                    Text("No completed tasks")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(primaryBlue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                } else {
                    ForEach(completedTasks.prefix(2)) { task in
                        TaskCardRow(task: task, isCompletedStyle: true)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(task)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.84, green: 0.91, blue: 1.0))
            )
        }
    }

    private var bottomBar: some View {
        HStack {
            tabItem(icon: "list.bullet", title: "Tasks", isActive: true)
            Spacer()
            tabItem(icon: "calendar", title: "Calendar", isActive: false)

            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.365, green: 0.592, blue: 0.902))
                    .frame(width: 52, height: 52)

                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .offset(y: -12)

            Spacer()
            tabItem(icon: "person", title: "Profile", isActive: false)
            Spacer()
            tabItem(icon: "checkmark", title: "Completed", isActive: false)
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
    }

    private func tabItem(icon: String, title: String, isActive: Bool) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isActive ? Color(red: 0.29, green: 0.44, blue: 0.68) : Color(red: 0.61, green: 0.63, blue: 0.68))

            Text(title)
                .font(.system(size: 8, weight: .medium, design: .rounded))
                .foregroundStyle(isActive ? Color(red: 0.29, green: 0.44, blue: 0.68) : Color(red: 0.56, green: 0.58, blue: 0.62))
        }
    }
}

private struct LayoutMetrics {
    let width: CGFloat
}

private enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case work = "Work"
    case personal = "Personal"
    case wishlist = "Wishlist"

    var id: String { rawValue }
    var title: String { rawValue }
}

private struct TaskCardRow: View {
    @Bindable var task: Task
    let isCompletedStyle: Bool

    private var taskAccentColor: Color {
        if task.status == "Done" {
            return Color(red: 0.18, green: 0.39, blue: 0.70)
        }

        switch task.category.lowercased() {
        case "work":
            return .red
        case "personal":
            return .purple
        case "wishlist":
            return .orange
        default:
            return .orange
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .stroke(taskAccentColor, lineWidth: 2)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(isCompletedStyle ? Color(red: 0.18, green: 0.37, blue: 0.62) : Color(red: 0.37, green: 0.39, blue: 0.44))
                    .strikethrough(isCompletedStyle)

                if let dueDate = task.dueDate {
                    Text("Due \(dueText(from: dueDate))")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.57, blue: 0.60))
                        .italic()
                }
            }

            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.84, green: 0.86, blue: 0.93), lineWidth: 1)
                )
        )
    }

    private func dueText(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }

        let weekday = date.formatted(.dateTime.weekday(.wide))
        let time = date.formatted(date: .omitted, time: .shortened)
        return "\(weekday) \(time)"
    }
}