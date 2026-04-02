import SwiftUI
import SwiftData

struct CalendarView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.dueDate) private var tasks: [Task]
 
    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()
 
    private let backgroundColor  = Color(red: 1.0,  green: 0.988, blue: 0.953)
    private let outlineColor     = Color(red: 0.84, green: 0.86,  blue: 0.93)
    private let shellBorderColor = Color(red: 0.93, green: 0.91,  blue: 0.86)
    private let primaryBlue      = Color(red: 0.18, green: 0.39,  blue: 0.70)
    private let softBlue         = Color(red: 0.84, green: 0.91,  blue: 1.00)
    private let textGray         = Color(red: 0.42, green: 0.42,  blue: 0.42)
 
    private let calendar = Calendar.current
    private let daySymbols = Calendar.current.veryShortWeekdaySymbols

    // MARK: - Computed Properties
    // Get all days to display in the calendar grid for the current month
    private var monthDays: [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
 
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7
 
        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        // Pad to complete last row
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    // Get tasks for a specific date, excluding completed ones
    private func tasks(for date: Date) -> [Task] {
        tasks.filter { task in
            guard let due = task.dueDate, task.status != "Done" else { return false }
            return calendar.isDate(due, inSameDayAs: date)
        }
    }
 
    // Get tasks for the selected date, sorted by due time
    private var selectedDateTasks: [Task] {
        tasks(for: selectedDate).sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }
    
    // Check if there are any incomplete tasks on a given date
    private func hasTasks(on date: Date) -> Bool {
        tasks.contains { task in
            guard let due = task.dueDate, task.status != "Done" else { return false }
            return calendar.isDate(due, inSameDayAs: date)
        }
    }
 
    // Group upcoming incomplete tasks by day label
    private var groupedUpcoming: [(label: String, tasks: [Task])] {
        let upcoming = tasks.filter { task in
            guard let due = task.dueDate, task.status != "Done" else { return false }
            return due >= calendar.startOfDay(for: Date())
        }
        let grouped = Dictionary(grouping: upcoming) { task -> Date in
            calendar.startOfDay(for: task.dueDate ?? Date())
        }
        return grouped.keys.sorted().map { date in
            let label: String
            if calendar.isDateInToday(date)    { label = "Today" }
            else if calendar.isDateInTomorrow(date) { label = "Tomorrow" }
            else { label = date.formatted(.dateTime.weekday(.wide)) }
            return (label: label, tasks: grouped[date]!.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) })
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
 
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            calendarCard
                            Divider().background(outlineColor)
                            agendaSection
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 100)
                    }
                }
                .overlay(alignment: .leading)  { Rectangle().fill(shellBorderColor).frame(width: 1) }
                .overlay(alignment: .trailing) { Rectangle().fill(shellBorderColor).frame(width: 1) }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Calendar Card
    private var calendarCard: some View {
        VStack(spacing: 10) {
            monthHeader
            weekdayLabels
            daysGrid
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(outlineColor, lineWidth: 1))
        )
    }

    // MARK: - Month Header
    private var monthHeader: some View {
        HStack(spacing: 8) {
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(primaryBlue)
                    .frame(width: 28, height: 28)
                    .background(softBlue.opacity(0.5))
                    .clipShape(Circle())
            }
 
            // Month picker
            Menu {
                ForEach(0..<12, id: \.self) { monthIndex in
                    Button {
                        var comps = calendar.dateComponents([.year, .month], from: displayedMonth)
                        comps.month = monthIndex + 1
                        if let newDate = calendar.date(from: comps) {
                            displayedMonth = newDate
                        }
                    } label: {
                        Text(monthName(monthIndex + 1))
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(displayedMonth.formatted(.dateTime.month(.wide)))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(primaryBlue)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(primaryBlue)
                }
            }
 
            // Year picker
            Menu {
                ForEach((2020...2030).reversed(), id: \.self) { year in
                    Button {
                        var comps = calendar.dateComponents([.year, .month], from: displayedMonth)
                        comps.year = year
                        if let newDate = calendar.date(from: comps) {
                            displayedMonth = newDate
                        }
                    } label: { Text("\(year)") }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(displayedMonth.formatted(.dateTime.year()))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(primaryBlue)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(primaryBlue)
                }
            }
 
            Spacer()
 
            Button {
                displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(primaryBlue)
                    .frame(width: 28, height: 28)
                    .background(softBlue.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Weekday Labels
    private var weekdayLabels: some View {
        HStack(spacing: 0) {
            ForEach(daySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(textGray)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Days Grid
    private var daysGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
 
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                if let date {
                    dayCell(date)
                } else {
                    Color.clear.frame(height: 36)
                }
            }
        }
    }

    // MARK: - Day Cell
    @ViewBuilder
    private func dayCell(_ date: Date) -> some View {
        let isToday    = calendar.isDateInToday(date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let hasTask    = hasTasks(on: date)
 
        Button {
            selectedDate = date
        } label: {
            ZStack(alignment: .bottom) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 13, weight: isToday || isSelected ? .bold : .regular, design: .rounded))
                    .foregroundStyle(
                        isSelected ? .white :
                        isToday    ? primaryBlue :
                                     Color(red: 0.25, green: 0.27, blue: 0.32)
                    )
                    .frame(width: 34, height: 34)
                    .background(
                        Group {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10).fill(primaryBlue)
                            } else if isToday {
                                RoundedRectangle(cornerRadius: 10).fill(softBlue)
                            } else {
                                Color.clear
                            }
                        }
                    )
 
                // Task dot
                if hasTask && !isSelected {
                    Circle()
                        .fill(primaryBlue.opacity(0.55))
                        .frame(width: 4, height: 4)
                        .offset(y: 2)
                }
            }
            .frame(height: 38)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Agenda Section
    private var agendaSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(groupedUpcoming, id: \.label) { group in
                agendaGroup(label: group.label, tasks: group.tasks)
            }
 
            if groupedUpcoming.isEmpty {
                Text("No upcoming tasks")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
    }
 
    private func agendaGroup(label: String, tasks: [Task]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(textGray)
 
            if tasks.isEmpty {
                Text("No tasks due")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 6)
            } else {
                VStack(spacing: 6) {
                    ForEach(tasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            agendaRow(task: task)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func agendaRow(task: Task) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(task.status == "To Do" ? "Due" : task.status)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(primaryBlue.opacity(0.7))
                if let due = task.dueDate {
                    Text(due.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(textGray)
                }
            }
            .frame(width: 52, alignment: .leading)
 
            Rectangle()
                .fill(categoryColor(for: task))
                .frame(width: 3)
                .cornerRadius(2)
 
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(red: 0.18, green: 0.22, blue: 0.30))
                    .lineLimit(1)
 
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes.components(separatedBy: "\n").first ?? "")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(textGray.opacity(0.8))
                        .lineLimit(1)
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
                .fill(Color.white.opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(outlineColor, lineWidth: 1))
        )
    }

    // MARK: - Helpers
    // Get color based on task category
    private func categoryColor(for task: Task) -> Color {
        switch task.category.lowercased() {
        case "work":     return .red
        case "personal": return .purple
        case "wishlist": return .orange
        default:         return primaryBlue
        }
    }
    
    // Get month name from month number
    private func monthName(_ month: Int) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        var comps = DateComponents(); comps.month = month; comps.year = 2000
        return df.string(from: Calendar.current.date(from: comps) ?? Date())
    }

    // MARK: - Preview
    #Preview {
        CalendarView()
            .modelContainer(for: Task.self, inMemory: true)
    }
}