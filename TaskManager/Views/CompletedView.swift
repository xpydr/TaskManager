import SwiftUI
import SwiftData

struct CompletedView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse)
    private var tasks: [Task]

    private let backgroundColor = Color(red: 1.0, green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86, blue: 0.93)
    private let shellBorderColor = Color(red: 0.93, green: 0.91, blue: 0.86)
    private let primaryBlue = Color(red: 0.18, green: 0.39, blue: 0.70)
    private let textGray = Color(red: 0.42, green: 0.42, blue: 0.42)
    
    private var completedTasks: [Task] {
        tasks.filter { $0.status == "Done" }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                backgroundColor.ignoresSafeArea()
                
                VStack {
                    
                    ScrollView {
                        VStack(spacing: 12) {
                          
                            Divider()
                                .background(outlineColor)
                            
                            // Task List
                            VStack(spacing: 8) {
                                if completedTasks.isEmpty {
                                    Text("No completed tasks")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 12)
                                } else {
                                    ForEach(completedTasks) { task in
                                        CompletedTaskRow(task: task)
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
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.4))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(outlineColor, lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                    
                    Spacer()
                }
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
            }
            .navigationTitle("Completed")
        }
    }
}

// MARK: - Row

struct CompletedTaskRow: View {
    
    let task: Task
    
    private let primaryBlue = Color(red: 0.18, green: 0.39, blue: 0.70)
    
    var body: some View {
        HStack(spacing: 10) {
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(primaryBlue)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(primaryBlue)
                    .strikethrough(true)
                
                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.84, green: 0.86, blue: 0.93), lineWidth: 1)
                )
        )
    }
}

// Preview

#Preview {
    CompletedView()
        .modelContainer(for: Task.self, inMemory: true)
}
