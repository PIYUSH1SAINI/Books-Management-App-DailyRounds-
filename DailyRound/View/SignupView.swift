import SwiftUI

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var selectedCountry: String = "Select your country"
    
    @State private var isEmailValid: Bool = true
    
    @StateObject private var viewModel = SignupViewViewModel()
    
    // Navigation state
    @State private var isSignupSuccessful: Bool = false
    
    var body: some View {
        VStack {
            Text("Sign up to continue")
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            
            Spacer()
            
            VStack(spacing: 30) {
                // Email Input
                emailTextField
                
                // Password Input
                passwordSecureField
                
                // Password Criteria Checkboxes
                passwordCriteriaView
                
                // Country Picker
                countryPicker
                
                Spacer()
                
                // Signup Button
                signupButton
            }
            .padding()
        }
        .navigationTitle("Welcome")
        .background(
            NavigationLink(destination: HomeView(), isActive: $isSignupSuccessful) {
                EmptyView()
            }
        )
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $email)
            .padding(.leading, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .padding(20)
                    .foregroundColor(.clear)
                    .border(Color.gray)
            )
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .onChange(of: email) { newValue in
                isEmailValid = viewModel.validateEmail(newValue)
            }
    }
    
    private var passwordSecureField: some View {
        SecureField("Password", text: $password)
            .padding(.leading, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .padding(20)
                    .foregroundColor(.clear)
                    .border(Color.gray)
            )
            .onChange(of: password) { newValue in
                viewModel.validatePasswordCriteria(newValue)
            }
    }
    
    private var passwordCriteriaView: some View {
        VStack(alignment: .leading) {
            criteriaCheck(title: "At least 8 characters", isValid: viewModel.hasMinLength)
            criteriaCheck(title: "Must contain an uppercase letter", isValid: viewModel.hasUpperCase)
            criteriaCheck(title: "Must contain a special character", isValid: viewModel.hasSpecialCharacter)
        }
        .padding(.leading)
    }
    
    private func criteriaCheck(title: String, isValid: Bool) -> some View {
        HStack {
            Image(systemName: isValid ? "checkmark.square" : "square")
                .foregroundColor(isValid ? .green : .gray)
            Text(title)
        }
    }
    
    private var countryPicker: some View {
        Picker("Country", selection: $selectedCountry) {
            ForEach(viewModel.countries, id: \.self) { country in
                Text(country).tag(country)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .onAppear {
            viewModel.loadCountryData()
        }
        .onChange(of: viewModel.selectedCountryCode) { _ in
            if let defaultCountry = viewModel.getCountryByCode(viewModel.selectedCountryCode ?? "") {
                selectedCountry = defaultCountry
            }
        }
        .onChange(of: selectedCountry) { newValue in
            viewModel.selectedCountry = newValue
        }
    }
    
    private var signupButton: some View {
        Button(action: {
            if isEmailValid && viewModel.isPasswordValid {
                viewModel.storeUserDetails(email: email, password: password, country: selectedCountry)
                isSignupSuccessful = true
            }
        }) {
            HStack {
                Text("Let's go")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.white)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(isEmailValid && viewModel.isPasswordValid ? Color.blue : Color.gray)
            .cornerRadius(10)
        }
        .disabled(!isEmailValid || !viewModel.isPasswordValid)
        .padding()
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
