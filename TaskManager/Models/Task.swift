import Foundation
import SwiftData

@Model
class Task {
    var title: String
    var category: String
    var status: String
    var dueDate: Date
    var notes: String?
    
    init(title: String, category: String = "Work", status: String = "To Do", dueDate: Date, notes: String? = nil) {
        self.title = title
        self.category = category
        self.status = status
        self.dueDate = dueDate
        self.notes = notes
    }
}
