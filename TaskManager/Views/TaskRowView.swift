import SwiftData
import SwiftUI

struct TaskRowView: View {
    @Bindable var task: Task

    var body: some View {
        HStack(spacing: 16) {
            // Status indicator (colored circle)
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(task.title)
                    .font(.headline)
                    .foregroundStyle(task.status == "Done" ? .secondary : .primary)
                    .strikethrough(task.status == "Done")

                HStack(spacing: 12) {
                    // Category pill
                    Text(task.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(categoryBackground)
                        .foregroundColor(categoryTextColor)
                        .cornerRadius(12)

                    // Due date (if exists)
                    if let dueDate = task.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(dueDateColor)
                        }
                    }
                }
            }

            Spacer()

            // Status text on the right
            Text(task.status)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusBackground)
                .cornerRadius(12)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Computed styling

    private var statusColor: Color {
        switch task.status {
        case "To Do": return .blue
        case "In Progress": return .orange
        case "Done": return .green
        default: return .gray
        }
    }

    private var categoryBackground: Color {
        task.category == "Work" ? Color.blue.opacity(0.1) : Color.purple.opacity(0.1)
    }

    private var categoryTextColor: Color {
        task.category == "Work" ? .blue : .purple
    }

    private var statusBackground: Color {
        statusColor.opacity(0.15)
    }

    private var dueDateColor: Color {
        if let dueDate = task.dueDate, dueDate < Date() {
            return .red // Overdue
        }
        return .secondary
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    
    let sampleTask = Task(
        title: "Finish Assignment",
        category: "Work",
        status: "In Progress",
        dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
        notes: "Complete the report section"
    )
    
    return TaskRowView(task: sampleTask)
        .modelContainer(container)
        .padding()
}
