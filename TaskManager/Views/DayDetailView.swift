import SwiftUI
import SwiftData

struct DayDetailView: View {

    let date: Date

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.dueDate) private var tasks: [Task]

    private let backgroundColor  = Color(red: 1.0,  green: 0.988, blue: 0.953)
    private let outlineColor     = Color(red: 0.84, green: 0.86,  blue: 0.93)
    private let shellBorderColor = Color(red: 0.93, green: 0.91,  blue: 0.86)
    private let primaryBlue      = Color(red: 0.18, green: 0.39,  blue: 0.70)
    private let textGray         = Color(red: 0.42, green: 0.42,  blue: 0.42)

    // Filter tasks for the specific date
    private var dayTasks: [Task] {
        tasks.filter { task in 
            guard let due = task.dueDate else { return false }
            return Calendar.current.isDate(due, inSameDayAs: date)
        }
        .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    // Navigation title based on the date
    private var navTitle: String {
        if Calendar.current.isDateInToday(date) {return "Today"}
        if Calendar.current.isDateInTomorrow(date) {return "Tomorrow"}
        if Calendar.current.isDateInYesterday(date) {return "Yesterday"}
        return date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }

    // MARK: - View Body
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
 
            if dayTasks.isEmpty {
                emptyState
            } else {
                taskList
            }
        }
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .leading)  { Rectangle().fill(shellBorderColor).frame(width: 1) }
        .overlay(alignment: .trailing) { Rectangle().fill(shellBorderColor).frame(width: 1) }
    }

    // MARK: - Task List
    private var taskList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
 
                // Date banner
                dateBanner
 
                // Tasks
                VStack(spacing: 8) {
                    ForEach(dayTasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            DayTaskRow(task: task)
                        }
                        .buttonStyle(.plain)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                modelContext.delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.4))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(outlineColor, lineWidth: 1))
                )
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Date Banner
    private var dateBanner: some View {
        HStack(spacing: 14) {
            // Big day number
            VStack(spacing: 0) {
                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryBlue)
                Text(date.formatted(.dateTime.month(.abbreviated)).uppercased())
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(primaryBlue.opacity(0.6))
            }
            .frame(width: 56, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(red: 0.84, green: 0.91, blue: 1.0))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(outlineColor, lineWidth: 1))
            )
 
            VStack(alignment: .leading, spacing: 3) {
                Text(date.formatted(.dateTime.weekday(.wide)))
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(primaryBlue)
 
                Text("\(dayTasks.count) task\(dayTasks.count == 1 ? "" : "s") scheduled")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(textGray)
            }
 
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(outlineColor, lineWidth: 1))
        )
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.system(size: 44))
                .foregroundStyle(primaryBlue.opacity(0.4))
 
            Text("No tasks for this day")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(textGray)
 
            Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(textGray.opacity(0.7))
        }
    }
}

// MARK: - Day Task Row
private struct DayTaskRow: View {

    let task: Task
 
    private let outlineColor = Color(red: 0.84, green: 0.86, blue: 0.93)
    private let primaryBlue  = Color(red: 0.18, green: 0.39, blue: 0.70)
    private let textGray     = Color(red: 0.42, green: 0.42, blue: 0.42)
 
    private var accentColor: Color {
        if task.status == "Done" { return primaryBlue }
        switch task.category.lowercased() {
        case "work":     return .red
        case "personal": return .purple
        case "wishlist": return .orange
        default:         return primaryBlue
        }
    }
 
    private var statusColor: Color {
        switch task.status {
        case "In Progress": return .orange
        case "Done":        return .green
        default:            return primaryBlue
        }
    }
 
    var body: some View {
        HStack(spacing: 10) {
 
            // Colored left bar
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)
                .cornerRadius(2)
 
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(task.status == "Done" ? textGray : Color(red: 0.18, green: 0.22, blue: 0.30))
                    .strikethrough(task.status == "Done")
 
                HStack(spacing: 8) {
                    if let due = task.dueDate {
                        Label(due.formatted(date: .omitted, time: .shortened),
                              systemImage: "clock")
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundStyle(textGray.opacity(0.8))
                    }
 
                    // Status pill
                    Text(task.status)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(statusColor)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(statusColor.opacity(0.3), lineWidth: 1))
                }
            }
 
            Spacer()
 
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(outlineColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(outlineColor, lineWidth: 1))
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        DayDetailView(date: Date())
    }
    .modelContainer(for: Task.self)
}