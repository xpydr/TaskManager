import SwiftUI
import SwiftData

struct TaskDetailView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var task: Task

    @State private var showDeleteConfirmation = false
    @State private var showEditView = false

    private let backgroundColor = Color(red: 1.0,  green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86,  blue: 0.93)
    private let shellBorderColor = Color(red: 0.93, green: 0.91,  blue: 0.86)
    private let primaryBlue = Color(red: 0.18, green: 0.39,  blue: 0.70)
    private let textGray = Color(red: 0.42, green: 0.42,  blue: 0.42)

    


}