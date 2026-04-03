import SwiftUI
import SwiftData

struct ProfileView: View {
    
    @State private var showEditProfile = false
    
    // Profile state
    @State private var name: String = "John Doe"
    @State private var email: String = "john@georgebrown.ca"
    
    @Query(sort: \Task.createdAt, order: .reverse)
    private var tasks: [Task]
    
    private let backgroundColor = Color(red: 1.0, green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86, blue: 0.93)
    private let primaryBlue = Color(red: 0.18, green: 0.39, blue: 0.70)
    private let textGray = Color(red: 0.42, green: 0.42, blue: 0.42)
    
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
            ZStack {
                
                backgroundColor.ignoresSafeArea()
                
                VStack {
                    
                    VStack(spacing: 16) {
                        
                        // Profile Icon
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.38, green: 0.67, blue: 1.0),
                                        Color(red: 0.16, green: 0.33, blue: 0.67)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(red: 0.12, green: 0.31, blue: 0.57))
                                        .frame(width: 28, height: 28)
                                    
                                    Capsule()
                                        .fill(Color(red: 0.12, green: 0.31, blue: 0.57))
                                        .frame(width: 60, height: 28)
                                }
                            )
                        
                        // Dynamic values
                        Text(name)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(primaryBlue)
                        
                        Text(email)
                            .foregroundStyle(textGray)
                        
                        Button("Edit Profile") {
                            showEditProfile = true
                        }
                        .padding()
                        .frame(maxWidth: 250)
                        .background(primaryBlue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        
                        // Stats
                        HStack(spacing: 16) {
                            StatBox(
                                number: "\(inProgressCount)",
                                label: "In Progress",
                                primaryBlue: primaryBlue,
                                outlineColor: outlineColor,
                                textGray: textGray
                            )
                            
                            StatBox(
                                number: "\(completedCount)",
                                label: "Completed",
                                primaryBlue: primaryBlue,
                                outlineColor: outlineColor,
                                textGray: textGray
                            )
                            
                            StatBox(
                                number: "\(todoCount)",
                                label: "To Do",
                                primaryBlue: primaryBlue,
                                outlineColor: outlineColor,
                                textGray: textGray
                            )
                        }
                    }
                    .padding()
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
            .navigationTitle("Profile")
            
            // ✅ Pass binding correctly
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(name: $name, email: $email)
            }
        }
    }
}

//////////////////////////////////////////////////////////
// MARK: - StatBox (KEEP THIS IN SAME FILE)
//////////////////////////////////////////////////////////

struct StatBox: View {
    let number: String
    let label: String
    
    let primaryBlue: Color
    let outlineColor: Color
    let textGray: Color
    
    var iconName: String {
        switch label {
        case "In Progress": return "clock.fill"
        case "Completed": return "checkmark"
        case "To Do": return "tray.fill"
        default: return "square"
        }
    }
    
    var iconBackgroundColor: Color {
        switch label {
        case "In Progress": return Color(red: 0.86, green: 0.93, blue: 0.95)
        case "Completed": return Color(red: 0.90, green: 0.95, blue: 0.90)
        case "To Do": return Color(red: 0.90, green: 0.90, blue: 0.90)
        default: return Color.gray.opacity(0.2)
        }
    }
    
    var iconForegroundColor: Color {
        switch label {
        case "In Progress": return Color(red: 0.40, green: 0.60, blue: 0.70)
        case "Completed": return Color(red: 0.45, green: 0.70, blue: 0.50)
        case "To Do": return Color.gray
        default: return Color.gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .foregroundColor(iconForegroundColor)
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Text(number)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(primaryBlue)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(textGray)
        }
        .frame(width: 100, height: 110)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(outlineColor, lineWidth: 1)
                )
        )
    }
}
