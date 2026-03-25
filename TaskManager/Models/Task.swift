import Foundation
import SwiftData

@Model
class Task {
    var title: String
    var category: String
    var status: String
    var dueDate: Date?
    var notes: String?
    var createdAt: Date

    init(
        title: String,
        category: String = "Work",
        status: String = "To Do",
        dueDate: Date,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.title = title
        self.category = category
        self.status = status
        self.dueDate = dueDate
        self.notes = notes
        self.createdAt = createdAt
    }
}
