SwiftUI
SwiftData

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
        if Calendar.current.isDateYesterday(date) {return "Yesterday"}
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

    // MARK: - Empty State




}


// MARK: - Day Task Row
private struct DayTaskRow: View {




}

// MARK: - Previews