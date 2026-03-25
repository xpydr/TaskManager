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
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HStack {
                            Button("Cancel") {
                                dismiss()
                            }
                            .foregroundColor(.blue)

                            Spacer()

                            Text("New Task")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Spacer()

                            // Placeholder for balance
                            Text("Save")
                                .foregroundColor(.clear)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 20) {
                            
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
                                        CategoryButton(title: category, isSelected: selectedCategory == category) {
                                            selectedCategory = category
                                        }
                                    }
                                    Button(action: {}) {
                                        Text("+ New")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.gray.opacity(0.15))
                                            .foregroundColor(.secondary)
                                            .cornerRadius(20)
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
                                        StatusButton(title: status, isSelected: selectedStatus == status) {
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
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
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
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal)

                        // Create Button
                        Button(action: save) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.title3)
                                Text("Create")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canSave ? Color.blue : Color.gray.opacity(0.6))
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .disabled(!canSave)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)  // Custom header instead of navigationTitle
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

// MARK: - Reusable Selection Buttons

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct StatusButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.white)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
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
