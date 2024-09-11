import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var users: [UserDetails] = []
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginValid: Bool = true
    @Published var loginError: String? = nil
    
    static var currentUserId: UUID?
    static var currentUserDetails: UserDetails?

    private let userDirectory = "UserDetails"
    
    var isLoggedIn: Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    // MARK: - Login Method
    func login() {
        print("Attempting to login with email: \(email)") // Debug
        
        // Validate credentials
        guard validateCredentials(email: email, password: password) else {
            print("Login failed: Invalid credentials for email: \(email)") // Debug
            isLoginValid = false
            loginError = "Invalid email or password. Please try again."
            return
        }
        
        // Set current user ID if credentials are valid
        if let currentUserIndex = users.firstIndex(where: { $0.email == email && $0.password == password }) {
            var currentUser = users[currentUserIndex]
            currentUser.loggedIn = true
            users[currentUserIndex] = currentUser
            saveUsers()
            
            print("Login successful for email: \(email). User ID: \(currentUser.id)") // Debug
            LoginViewModel.currentUserId = currentUser.id
            LoginViewModel.currentUserDetails = currentUser
            print("currentUserId = \(String(describing: LoginViewModel.currentUserId))")
            print("currentUserDetails = \(String(describing: LoginViewModel.currentUserDetails))")
            print("all users - \(users)")
            
            // Store login state
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(email, forKey: "currentLoggedInEmail")
            
            isLoginValid = true
        } else {
            print("No user found matching email: \(email) and password") // Debug
        }
    }

    // MARK: - Logout Method
    func logout() {
        print("User logged out for email: \(String(describing: LoginViewModel.currentUserDetails?.email))") // Debug
        if let currentUserId = LoginViewModel.currentUserId,
           let currentUserIndex = users.firstIndex(where: { $0.id == currentUserId }) {
            var currentUser = users[currentUserIndex]
            currentUser.loggedIn = false
            users[currentUserIndex] = currentUser
            saveUsers()
        }
        
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentLoggedInEmail")
        LoginViewModel.currentUserId = nil 
        LoginViewModel.currentUserDetails = nil
    }
    
    // MARK: - Save Users to File
    private func saveUsers() {
        let fileManager = FileManager.default
        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userDir = documentsURL.appendingPathComponent(userDirectory)
            
            // Create directory if it doesn't exist
            if !fileManager.fileExists(atPath: userDir.path) {
                try fileManager.createDirectory(at: userDir, withIntermediateDirectories: true, attributes: nil)
            }
            
            let usersFileURL = userDir.appendingPathComponent("users.json")
            let data = try JSONEncoder().encode(users)
            try data.write(to: usersFileURL)
            
            print("Users successfully saved to file") // Debug
        } catch {
            print("Error saving users to file: \(error)") // Debug
        }
    }

    
    // MARK: - Credential Validation
    private func validateCredentials(email: String, password: String) -> Bool {
        print("Validating credentials for email: \(email)") // Debug
        
        // Find matching user details
        if let userDetails = users.first(where: { $0.email == email && $0.password == password }) {
            print("User found for email: \(email), User ID: \(userDetails.id)") // Debug
            return true
        } else {
            print("No matching user found for email: \(email)") // Debug
            return false
        }
    }
    
    // MARK: - Load Users from File
    private func loadUsers() -> [UserDetails]? {
        let fileManager = FileManager.default
        do {
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userDir = documentsURL.appendingPathComponent(userDirectory)
            let usersFileURL = userDir.appendingPathComponent("users.json")
            
            print("Attempting to load users from file: \(usersFileURL.path)") // Debug
            
            // Check if the file exists
            if fileManager.fileExists(atPath: usersFileURL.path) {
                let data = try Data(contentsOf: usersFileURL)
                let loadedUsers = try JSONDecoder().decode([UserDetails].self, from: data)
                print("Users successfully loaded from file") // Debug
                return loadedUsers
            } else {
                print("No users found at path: \(usersFileURL.path)") // Debug
                return nil
            }
        } catch {
            print("Error loading users from file: \(error)") // Debug
            return nil
        }
    }
    
    // MARK: - Initializer
    init() {
        print("Initializing LoginViewModel...") // Debug
        if let users = loadUsers() {
            print("Users successfully loaded in initializer") // Debug
            self.users = users
            
            // Check logged-in user
            if let email = UserDefaults.standard.string(forKey: "currentLoggedInEmail"),
               let currentUser = users.first(where: { $0.email == email }) {
                LoginViewModel.currentUserId = currentUser.id
                LoginViewModel.currentUserDetails = currentUser
            }
        } else {
            print("No users were loaded in initializer") // Debug
        }
    }
}
