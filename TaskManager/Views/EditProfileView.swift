import SwiftUI

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = "John Doe"
    @State private var email: String = "john@georgebrown.ca"
    
    private let backgroundColor = Color(red: 1.0, green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86, blue: 0.93)
    private let primaryBlue = Color(red: 0.18, green: 0.39, blue: 0.70)
    private let textGray = Color(red: 0.42, green: 0.42, blue: 0.42)
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
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
                        .frame(width: 100, height: 100)
                        .overlay(
                            VStack(spacing: 6) {
                                Circle()
                                    .fill(Color(red: 0.12, green: 0.31, blue: 0.57))
                                    .frame(width: 24, height: 24)
                                
                                Capsule()
                                    .fill(Color(red: 0.12, green: 0.31, blue: 0.57))
                                    .frame(width: 50, height: 24)
                            }
                        )
                        .padding(.top, 20)
                    
                    // Name Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(.caption)
                            .foregroundStyle(textGray)
                        
                        TextField("Enter name", text: $name)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(outlineColor, lineWidth: 1)
                            )
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.caption)
                            .foregroundStyle(textGray)
                        
                        TextField("Enter email", text: $email)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(outlineColor, lineWidth: 1)
                            )
                            .keyboardType(.emailAddress)
                    }
                    
                    Spacer()
                    
                    // Save Button
                    Button("Save") {
                        dismiss()
                    }
                    .padding()
                    .frame(width: 200)
                    .background(primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
