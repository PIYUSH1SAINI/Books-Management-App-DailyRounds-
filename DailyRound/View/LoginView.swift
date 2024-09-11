import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToHome = false
    
    var body: some View {
        VStack {
            Text("Log in to continue")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            Spacer()
            
            VStack(spacing: 30) {
                // Email Input
                emailTextField
                
                // Password Input
                passwordSecureField
                
                // Error Message
                if !viewModel.isLoginValid {
                    Text("Invalid email or password")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Login Button
                loginButton
            }
            .padding()
            
            // Navigation Link
            NavigationLink(
                destination: HomeView(),
                isActive: $navigateToHome,
                label: { EmptyView() }
            )
        }
        .navigationTitle("Welcome")
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $viewModel.email)
            .keyboardType(.emailAddress)
            .padding(.leading, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .padding(20)
                    .foregroundColor(.clear)
                    .border(Color.gray)
            )
    }
    
    private var passwordSecureField: some View {
        SecureField("Password", text: $viewModel.password)
            .padding(.leading, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .padding(20)
                    .foregroundColor(.clear)
                    .border(Color.gray)
            )
    }
    
    private var loginButton: some View {
        Button(action: {
            viewModel.login()
            if viewModel.isLoginValid {
                navigateToHome = true
            }
        }) {
            HStack {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
        }
        .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
