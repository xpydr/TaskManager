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
 
            // Side border lines
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

    // MARK: - Navigation Bar
    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(primaryBlue)
            }
 
            Spacer()
 
            Text("Task Details")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(primaryBlue)
 
            Spacer()
 
            // Placeholder for spacing
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(primaryBlue)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(backgroundColor)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(outlineColor)
                .frame(height: 1)
        }
    }

    // MARK: - Title Section
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
 
            Text(task.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(primaryBlue)
                .fixedSize(horizontal: false, vertical: true)
 
            // Due date + time
            if let due = task.dueDate {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Due \(due.formatted(date: .long, time: .omitted))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(isOverdue ? .red : textGray)
 
                    Text("At \(due.formatted(date: .omitted, time: .shortened)) EST")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(isOverdue ? .red.opacity(0.8) : textGray.opacity(0.8))
                }
            }
 
            // Tags row
            HStack(spacing: 8) {
                // Category tag
                tagPill(label: task.category, color: categoryColor)
 
                // Status tag
                tagPill(label: statusTag.label, color: statusTag.color)
 
                // Overdue/Time-sensitive tag
                if isOverdue {
                    tagPill(label: "Overdue", color: .red)
                } else if let due = task.dueDate,
                          due.timeIntervalSinceNow < 60 * 60 * 24 * 3 && !isDone {
                    tagPill(label: "Time Sensitive", color: Color(red: 0.85, green: 0.45, blue: 0.20))
                }
            }
        }
    }

    // Function for tags to reduce code duplication
    private func tagPill(label: String, color: Color) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.35), lineWidth: 1))
    }

    // Maark: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let notes = task.notes, !notes.isEmpty {
                // Render each line as a bullet point
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(notes.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }, id: \.self) { line in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(primaryBlue.opacity(0.6))
                            Text(line.trimmingCharacters(in: .whitespaces))
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(textGray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
 
            Divider().background(outlineColor).padding(.vertical, 4)
 
            // Edit notes link
            Button {
                showEditSheet = true
            } label: {
                Text("Edit")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(textGray.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(outlineColor, lineWidth: 1))
        )
    }

    




}