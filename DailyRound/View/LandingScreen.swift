import SwiftUI

struct LandingScreen: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("Welcome to MedBook")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Add What you like")
                .font(.title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Image("LandingScreenImage")
                .resizable()
                .scaledToFit()
            
            HStack(spacing: 20) {
                NavigationLink(destination: SignupView()) {
                    CustomButton(title: "Sign Up", backgroundColor: .blue)
                }
                
                NavigationLink(destination: LoginView()) {
                    CustomButton(title: "Log In", backgroundColor: .green)
                }
            }
            .padding()
        }
        .navigationTitle("MedBook")
    }
}

struct CustomButton: View {
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        Text(title)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(backgroundColor)
            .cornerRadius(10)
    }
}

struct LandingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreen()
    }
}
