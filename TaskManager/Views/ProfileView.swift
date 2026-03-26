import SwiftUI
import SwiftData

struct ProfileView: View {
    
    @Query(sort: \Task.createdAt, order: .reverse)
    private var tasks: [Task]
    
    // Stats
    
    var inProgressCount: Int {
        tasks.filter { $0.status == "In Progress" }.count
    }
    
    var completedCount: Int {
        tasks.filter { $0.status == "Done" }.count
    }
    
    var todoCount: Int {
        tasks.filter { $0.status == "To Do" }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                VStack(spacing: 16) {
                    
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.blue)
                    
                    Text("John Doe")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("john@georgebrown.ca")
                        .foregroundColor(.gray)
                    
                    Button("Edit Profile") {
                      
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
                    // Stats
                    
                    HStack(spacing: 16) {
                        StatBox(number: "\(inProgressCount)", label: "In Progress")
                        StatBox(number: "\(completedCount)", label: "Completed")
                        StatBox(number: "\(todoCount)", label: "To Do")
                    }
                }
                .padding()
                .padding(.top, 40)
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Reusable Stat Box

struct StatBox: View {
    let number: String
    let label: String
    
    var iconName: String {
        switch label {
        case "In Progress": return "clock.fill"
        case "Completed": return "checkmark.circle.fill"
        case "To Do": return "tray.fill"
        default: return "square"
        }
    }
    
    var iconColor: Color {
        switch label {
        case "In Progress": return .blue
        case "Completed": return .green
        case "To Do": return .gray
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(iconColor)
            
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// Preview

#Preview {
    ProfileView()
        .modelContainer(for: Task.self, inMemory: true)
}
