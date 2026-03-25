import SwiftData
import SwiftUI

struct TaskRowView: View {
    @Bindable var task: Task

    var body: some View {
        HStack {
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
            Spacer()
            Toggle("Completed", isOn: $task.isCompleted)
                .labelsHidden()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Task.self, configurations: config)
    let task = Task(title: "Sample task")
    return TaskRowView(task: task)
        .modelContainer(container)
}
