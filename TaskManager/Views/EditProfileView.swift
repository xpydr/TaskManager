import SwiftUI

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Binding var name: String
    @Binding var email: String
    
    private let backgroundColor = Color(red: 1.0, green: 0.988, blue: 0.953)
    private let outlineColor = Color(red: 0.84, green: 0.86, blue: 0.93)
    private let primaryBlue = Color(red: 0.18, green: 0.39, blue: 0.70)
    private let textGray = Color(red: 0.42, green: 0.42, blue: 0.42)
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
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
                        .padding(.top, 20)
                    
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
                                    .allowsHitTesting(false)
                            )
                    }
                    
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
    EditProfileView(
        name: .constant("John Doe"),
        email: .constant("john@georgebrown.ca")
    )
}
