import Foundation

// MARK: - User Details Model

/// Model for user details including bookmarks
struct UserDetails: Codable, Identifiable {
    var id: UUID
    var email: String
    var password: String
    var country: String
    var loggedIn: Bool
    var bookmarks: [Bookmark] // Array of bookmarks associated with the user
    
    init(id: UUID = UUID(), email: String, password: String, country: String, loggedIn: Bool, bookmarks: [Bookmark] = []) {
        self.id = id
        self.email = email
        self.password = password
        self.country = country
        self.loggedIn = loggedIn
        self.bookmarks = bookmarks
    }
}

// MARK: - Bookmark Model

/// Model for a bookmark including details about a book
struct Bookmark: Identifiable, Codable {
    var id: String
    var title: String
    var ratingAverage: Double
    var ratingCount: Int
    var coverID: String
}

// MARK: - Country Struct

/// Model for country information
struct Country: Identifiable {
    var id: String { code }
    let code: String
    let name: String
}

// MARK: - Countries API Response

/// Response model for fetching countries data
struct CountriesResponse: Codable {
    let data: [String: CountryData]
}

struct CountryData: Codable {
    let country: String
}

// MARK: - IP Info API Response

/// Response model for IP information including location details
struct IPInfo: Codable {
    let city: String
    let region: String
    let country: String
    let loc: String
    let org: String
    let postal: String
    let timezone: String
}
