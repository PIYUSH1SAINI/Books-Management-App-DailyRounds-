import SwiftUI
import Combine

class BookmarkViewModel: ObservableObject {
    @Published var bookmarks: [Bookmark] = []
    
    private let userDirectory = "UserDetails"
    
    // MARK: - Load Bookmarks
    func loadBookmarks() {
        guard let currentUser = LoginViewModel.currentUserDetails else {
            print("No user is currently logged in.") // Debug
            return
        }
        
        // Load the user's bookmarks if they exist
        bookmarks = currentUser.bookmarks
        print("Bookmarks loaded for user: \(currentUser.email)") // Debug
    }
    
    // MARK: - Add Bookmark
    func addBookmark(_ bookmark: Bookmark) {
        guard var currentUser = LoginViewModel.currentUserDetails else {
            print("No user is currently logged in.") // Debug
            return
        }
        
        // Append the bookmark to the user's bookmark array
        currentUser.bookmarks.append(bookmark)
        
        // Update the currentUserDetails
        LoginViewModel.currentUserDetails = currentUser
        
        // Update bookmarks locally for this view model
        bookmarks.append(bookmark)
        
        // Save the updated user details
        saveUserDetailsToStorage(currentUser)
        
        print("Bookmark added for user: \(currentUser.email)") // Debug
    }
    
    // MARK: - Remove Bookmark
    func removeBookmark(_ bookmark: Bookmark) {
        guard var currentUser = LoginViewModel.currentUserDetails else {
            print("No user is currently logged in.") // Debug
            return
        }
        
        // Remove the bookmark from the user's bookmark array
        if let index = currentUser.bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            currentUser.bookmarks.remove(at: index)
            
            // Update currentUserDetails
            LoginViewModel.currentUserDetails = currentUser
            
            // Update bookmarks locally for this view model
            bookmarks.remove(at: index)
            
            // Save the updated user details
            saveUserDetailsToStorage(currentUser)
            
            print("Bookmark removed for user: \(currentUser.email)") // Debug
        } else {
            print("Bookmark not found for user: \(currentUser.email)") // Debug
        }
    }
    
    // MARK: - Delete Bookmark
    func deleteBookmark(withId bookmarkId: String) {
        guard var currentUser = LoginViewModel.currentUserDetails else {
            print("No user is currently logged in.") // Debug
            return
        }
        
        // Find and remove the bookmark with the given ID
        if let index = currentUser.bookmarks.firstIndex(where: { $0.id == bookmarkId }) {
            currentUser.bookmarks.remove(at: index)
            
            // Update currentUserDetails
            LoginViewModel.currentUserDetails = currentUser
            
            // Update bookmarks locally for this view model
            bookmarks.remove(at: index)
            
            // Save the updated user details
            saveUserDetailsToStorage(currentUser)
            
            print("Bookmark with ID \(bookmarkId) removed for user: \(currentUser.email)") // Debug
        } else {
            print("Bookmark with ID \(bookmarkId) not found for user: \(currentUser.email)") // Debug
        }
    }
    
    // MARK: - Save Updated User Details
    private func saveUserDetailsToStorage(_ updatedUser: UserDetails) {
        let fileManager = FileManager.default
        do {
            // Load existing users from local storage
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let userDir = documentsURL.appendingPathComponent(userDirectory)
            let usersFileURL = userDir.appendingPathComponent("users.json")
            
            var users = [UserDetails]()
            
            // Check if the users file exists
            if fileManager.fileExists(atPath: usersFileURL.path) {
                let data = try Data(contentsOf: usersFileURL)
                users = try JSONDecoder().decode([UserDetails].self, from: data)
            }
            
            // Check if the current user is already in the list
            if let index = users.firstIndex(where: { $0.id == updatedUser.id }) {
                // Update existing user
                users[index] = updatedUser
            } else {
                // Add new user
                users.append(updatedUser)
            }
            
            // Save the updated users array back to local storage
            let data = try JSONEncoder().encode(users)
            if !fileManager.fileExists(atPath: userDir.path) {
                try fileManager.createDirectory(at: userDir, withIntermediateDirectories: true, attributes: nil)
            }
            try data.write(to: usersFileURL)
            
            print("User details updated successfully for user: \(updatedUser.email)")
        } catch {
            print("Error saving user details: \(error)")
        }
    }
}
