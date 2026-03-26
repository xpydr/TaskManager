import SwiftData
import SwiftUI

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var selectedCategory: String = "Work"
    @State private var selectedStatus: String = "To Do"
    @State private var dueDate: Date = Date()
    @State private var notes: String = ""

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedTitle.isEmpty
    }

    let categories = ["Work", "Personal"]
    let statuses = ["To Do", "In Progress", "Done"]

    var body: some View {
        GeometryReader { geometry in
            let metrics = AddTaskMetrics(width: geometry.size.width)

            NavigationStack {
                ZStack {
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: metrics.stackSpacing) {
                            HStack {
                                Button("Cancel") {
                                    dismiss()
                                }
                                .foregroundColor(.blue)

                                Spacer()

                                Text("New Task")
                                    .font(.system(size: metrics.titleSize, weight: .semibold, design: .rounded))

                                Spacer()

                                Text("Save")
                                    .foregroundColor(.clear)
                            }
                            .padding(.horizontal, metrics.horizontalPadding)
                            .padding(.top, metrics.topPadding)

                            VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                            
                            // Title
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Title")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                TextField("Finish Assignment...", text: $title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            // Category
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Category")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        CategoryButton(title: category, isSelected: selectedCategory == category, metrics: metrics) {
                                            selectedCategory = category
                                        }
                                    }
                                    Button(action: {}) {
                                        Text("+ New")
                                            .font(.system(size: metrics.buttonLabelSize, weight: .medium, design: .rounded))
                                            .fontWeight(.medium)
                                            .padding(.horizontal, metrics.pillHorizontal)
                                            .padding(.vertical, metrics.pillVertical)
                                            .background(Color.gray.opacity(0.15))
                                            .foregroundColor(.secondary)
                                            .cornerRadius(metrics.pillCorner)
                                    }
                                }
                            }

                            // Status
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Status")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    ForEach(statuses, id: \.self) { status in
                                        StatusButton(title: status, isSelected: selectedStatus == status, metrics: metrics) {
                                            selectedStatus = status
                                        }
                                    }
                                }
                            }

                            // Due Date
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Due")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                HStack {
                                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(metrics.inputCorner)
                                .overlay(
                                    RoundedRectangle(cornerRadius: metrics.inputCorner)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .overlay {
                                    DatePicker(
                                        "",
                                        selection: $dueDate,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .colorMultiply(.clear)
                                }
                            }

                            // Notes
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                TextEditor(text: $notes)
                                    .frame(height: metrics.notesHeight)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(metrics.inputCorner)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: metrics.inputCorner)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, metrics.horizontalPadding)

                        // Create Button
                        Button(action: save) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.title3)
                                Text("Create")
                                    .font(.system(size: metrics.buttonTextSize, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, metrics.createButtonVertical)
                            .background(canSave ? Color.blue : Color.gray.opacity(0.6))
                            .cornerRadius(metrics.createButtonCorner)
                        }
                        .padding(.horizontal, metrics.horizontalPadding)
                        .padding(.top, 12)
                        .disabled(!canSave)

                        Spacer(minLength: metrics.bottomSpacer)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }

    private func save() {
        guard canSave else { return }
        
        let task = Task(
            title: trimmedTitle,
            category: selectedCategory,
            status: selectedStatus,
            dueDate: dueDate,
            notes: notes.isEmpty ? nil : notes
        )
        
        modelContext.insert(task)
        dismiss()
    }
}

private struct AddTaskMetrics {
    let width: CGFloat

    var compact: Bool { width < 360 }
    var regular: Bool { width > 410 }

    var horizontalPadding: CGFloat { compact ? 14 : 16 }
    var topPadding: CGFloat { compact ? 6 : 8 }
    var stackSpacing: CGFloat { compact ? 20 : 24 }
    var sectionSpacing: CGFloat { compact ? 16 : 20 }

    var titleSize: CGFloat { compact ? 21 : 23 }
    var buttonLabelSize: CGFloat { compact ? 13 : 14 }
    var buttonTextSize: CGFloat { compact ? 16 : 17 }

    var inputCorner: CGFloat { compact ? 10 : 12 }
    var notesHeight: CGFloat { compact ? 110 : 120 }

    var pillHorizontal: CGFloat { compact ? 12 : 16 }
    var pillVertical: CGFloat { compact ? 7 : 8 }
    var pillCorner: CGFloat { compact ? 18 : 20 }

    var createButtonVertical: CGFloat { compact ? 14 : 16 }
    var createButtonCorner: CGFloat { compact ? 14 : 16 }
    var bottomSpacer: CGFloat { compact ? 24 : 40 }
}

// MARK: - Reusable Selection Buttons

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let metrics: AddTaskMetrics
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: metrics.buttonLabelSize, weight: .medium, design: .rounded))
                .fontWeight(.medium)
                .padding(.horizontal, metrics.pillHorizontal)
                .padding(.vertical, metrics.pillVertical)
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(metrics.pillCorner)
                .overlay(
                    RoundedRectangle(cornerRadius: metrics.pillCorner)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct StatusButton: View {
    let title: String
    let isSelected: Bool
    let metrics: AddTaskMetrics
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: metrics.buttonLabelSize, weight: .medium, design: .rounded))
                .fontWeight(.medium)
                .padding(.horizontal, metrics.pillHorizontal)
                .padding(.vertical, metrics.pillVertical)
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(metrics.pillCorner)
                .overlay(
                    RoundedRectangle(cornerRadius: metrics.pillCorner)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    AddTaskView()
        .modelContainer(for: Task.self, inMemory: true)
}
