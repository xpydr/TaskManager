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

}