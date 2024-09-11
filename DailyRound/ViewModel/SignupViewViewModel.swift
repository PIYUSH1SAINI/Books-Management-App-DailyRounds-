import Foundation
import Combine

// MARK: - ViewModel Definition

class SignupViewViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var countries: [String] = []
    @Published var selectedCountryCode: String?
    @Published var selectedCountry: String = "Select your country"
    
    @Published var hasMinLength: Bool = false
    @Published var hasUpperCase: Bool = false
    @Published var hasSpecialCharacter: Bool = false
    @Published var isPasswordValid: Bool = true
    
    // MARK: - Private Properties
    
    private var users: [UserDetails] = []
    
    // MARK: - Initializer
    
    init() {
        loadUserDetails()
        loadCountryData()
    }
    
    // MARK: - Public Methods
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func validatePasswordCriteria(_ password: String) {
        hasMinLength = password.count >= 8
        hasUpperCase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        hasSpecialCharacter = password.range(of: "[!@#$%^&*]", options: .regularExpression) != nil
        isPasswordValid = hasMinLength && hasUpperCase && hasSpecialCharacter
    }
    
    func loadCountryData() {
        if let savedCountries = loadCountriesFromLocalDB() {
            self.countries = savedCountries
        } else {
            fetchCountries()
        }
        fetchIPCountry()
    }
    
    func storeUserDetails(email: String, password: String, country: String) {
        let userId = UUID().uuidString
        let newUser = UserDetails(id: UUID(uuidString: userId)!, email: email, password: password, country: country, loggedIn: true)
        
        // Store the new user details
        users.append(newUser)
        saveUsers()
        
        // Update UserDefaults
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(password, forKey: "userPassword")
        UserDefaults.standard.set(country, forKey: "userCountry")
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        
        // Update currentUserId and currentUserDetails
        LoginViewModel.currentUserId = newUser.id
        LoginViewModel.currentUserDetails = newUser
        UserDefaults.standard.set(newUser.id.uuidString, forKey: "currentUserId")
        
        // Debug
        print("New user signed up with email: \(email). User ID: \(newUser.id)")
        print("currentUserId = \(String(describing: LoginViewModel.currentUserId))")
        print("currentUserDetails = \(String(describing: LoginViewModel.currentUserDetails))")
    }
    
    func getCountryByCode(_ code: String) -> String? {
        return countries.first { $0.contains(code) }
    }
    
    // MARK: - Private Methods
    
    private func fetchCountries() {
        let url = URL(string: "https://api.first.org/data/v1/countries")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let result = try JSONDecoder().decode(CountriesResponse.self, from: data)
                let countryList = result.data.map { $0.value.country }
                DispatchQueue.main.async {
                    self.countries = countryList
                    self.saveCountriesToLocalDB(countries: countryList)
                }
            } catch {
                print("Failed to decode country data: \(error)")
            }
        }.resume()
    }
    
    private func fetchIPCountry() {
        let url = URL(string: "https://ipinfo.io/json?token=fb04d469a47620")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let ipData = try JSONDecoder().decode(IPInfo.self, from: data)
                DispatchQueue.main.async {
                    self.selectedCountryCode = ipData.country
                    if let defaultCountry = self.getCountryByCode(ipData.country) {
                        self.selectedCountry = defaultCountry
                        UserDefaults.standard.set(defaultCountry, forKey: "defaultCountry")
                    }
                }
            } catch {
                print("Failed to decode IP data: \(error)")
            }
        }.resume()
    }
    
    private func saveCountriesToLocalDB(countries: [String]) {
        // Implement saving logic
    }
    
    private func loadCountriesFromLocalDB() -> [String]? {
        // Implement retrieval logic
        return nil
    }
    
    private func loadUserDetails() {
        let fileManager = FileManager.default
        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userDir = documentsURL.appendingPathComponent("UserDetails")
            let usersFileURL = userDir.appendingPathComponent("users.json")
            
            if fileManager.fileExists(atPath: usersFileURL.path) {
                let data = try Data(contentsOf: usersFileURL)
                users = try JSONDecoder().decode([UserDetails].self, from: data)
            }
        } catch {
            print("Error loading users: \(error)")
        }
    }
    
    private func saveUsers() {
        let fileManager = FileManager.default
        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userDir = documentsURL.appendingPathComponent("UserDetails")
            if !fileManager.fileExists(atPath: userDir.path) {
                try fileManager.createDirectory(at: userDir, withIntermediateDirectories: true, attributes: nil)
            }
            let usersFileURL = userDir.appendingPathComponent("users.json")
            let data = try JSONEncoder().encode(users)
            try data.write(to: usersFileURL)
        } catch {
            print("Error saving users: \(error)")
        }
    }
}
