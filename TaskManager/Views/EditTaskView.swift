import SwiftUI
import SwiftData

struct EditTaskView: View {

    @Environment(\.dismiss) private var dismiss
    @Bindable var task: Task
 
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedStatus: String = "To Do"
    @State private var selectedCategory: String = "Work"
 
    private let backgroundColor = Color(red: 1.0,  green: 0.988, blue: 0.953)
    private let outlineColor    = Color(red: 0.84, green: 0.86,  blue: 0.93)
    private let primaryBlue     = Color(red: 0.18, green: 0.39,  blue: 0.70)
    private let textGray        = Color(red: 0.42, green: 0.42,  blue: 0.42)
 
    let categories = ["Work", "Personal", "Wishlist"]
    let statuses   = ["To Do", "In Progress", "Done"]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
 
                        // Title
                        fieldSection(label: "Title") {
                            TextField("Task title", text: $title)
                                .padding(10)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(outlineColor, lineWidth: 1))
                        }
 
                        // Category
                        fieldSection(label: "Category") {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { cat in
                                    pillButton(cat, isSelected: selectedCategory == cat) { selectedCategory = cat }
                                }
                            }
                        }
 
                        // Status
                        fieldSection(label: "Status") {
                            HStack(spacing: 10) {
                                ForEach(statuses, id: \.self) { s in
                                    pillButton(s, isSelected: selectedStatus == s) { selectedStatus = s }
                                }
                            }
                        }
 
                        // Due Date
                        fieldSection(label: "Due Date") {
                            HStack {
                                Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "calendar").foregroundStyle(primaryBlue)
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(outlineColor, lineWidth: 1))
                            .overlay {
                                DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .colorMultiply(.clear)
                            }
                        }
 
                        // Notes
                        fieldSection(label: "Notes") {
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(8)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(outlineColor, lineWidth: 1))
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        task.title    = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        task.notes    = notes.isEmpty ? nil : notes
                        task.dueDate  = dueDate
                        task.status   = selectedStatus
                        task.category = selectedCategory
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                title            = task.title
                notes            = task.notes ?? ""
                dueDate          = task.dueDate ?? Date()
                selectedStatus   = task.status
                selectedCategory = task.category
            }
        }
    }

    // Function for creating labeled sections in the form
    private func fieldSection<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(textGray)
            content()
        }
    }
    
    // Function for creating pill buttons for category and status selection
    private func pillButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? primaryBlue : Color.white)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isSelected ? Color.clear : outlineColor, lineWidth: 1))
        }
    }
}

// MARK: - Preview
#Preview {
    EditTaskView(task: Task(title: "Example Task", notes: "This is an example task for previewing the EditTaskView.", dueDate: Date().addingTimeInterval(3600), status: "To Do", category: "Work"))
}