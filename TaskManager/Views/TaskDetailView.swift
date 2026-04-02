import SwiftUI
import SwiftData

struct TaskDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Task

    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false

    private let backgroundColor = Color(red: 1.0,  green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86,  blue: 0.93)
    private let shellBorderColor = Color(red: 0.93, green: 0.91,  blue: 0.86)
    private let primaryBlue = Color(red: 0.18, green: 0.39,  blue: 0.70)
    private let textGray = Color(red: 0.42, green: 0.42,  blue: 0.42)

    // MARK: - Helpers
    private var isDone: Bool {task.status == "Done"}

    private var statusTage: (label: String, color: Color) {
        switch task.status {
        case "In Progress": return ("In Progress", .orange)
        case "Done": return ("Completed", .green)
        default: return ("Upcoming", .primaryBlue)
        }
    }

    private var categoryColor: Color {
        switch task.category.lowercased() {
        case "work": return .red
        case "personal": return .purple
        case "wishlist": return .orange
        default: return .primaryBlue
        }
    }

    private var isOverdue: Bool {
        guard let dueDate = task.dueDate, !isDone else { return false }
        return dueDate < Date()
    }

    // MARK: - Body View Components
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
 
            VStack(spacing: 0) {
                navBar
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        titleSection
                        if task.notes != nil { notesCard }
                        actionButtons
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
 
            // Side border lines (consistent with other views)
            .overlay(alignment: .leading)  { Rectangle().fill(shellBorderColor).frame(width: 1) }
            .overlay(alignment: .trailing) { Rectangle().fill(shellBorderColor).frame(width: 1) }
        }
        .navigationBarHidden(true)
        .confirmationDialog("Delete this task?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(task)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showEditSheet) {
            EditTaskView(task: task)
        }
    }




}