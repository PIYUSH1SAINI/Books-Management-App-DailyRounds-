import Foundation

// MARK: - Book Model

/// Model representing a book
struct Book: Identifiable, Codable {
    var id: String
    var title: String
    var ratingAverage: Double
    var ratingCount: Int
    var coverID: String
}

// MARK: - Book Search Response

/// Response model for book search API
struct BookSearchResponse: Decodable {
    let docs: [BookDocument]
}

// MARK: - Book Document

/// Document model representing a single book in search results
struct BookDocument: Decodable {
    let key: String
    let title: String
    let ratings_average: Double?
    let ratings_count: Int?
    let cover_i: CoverID?

    enum CodingKeys: String, CodingKey {
        case key
        case title
        case ratings_average
        case ratings_count
        case cover_i
    }

    // Custom decoding to handle `cover_i` as either String or Int
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        key = try container.decode(String.self, forKey: .key)
        title = try container.decode(String.self, forKey: .title)
        ratings_average = try container.decodeIfPresent(Double.self, forKey: .ratings_average)
        ratings_count = try container.decodeIfPresent(Int.self, forKey: .ratings_count)
        
        if let coverIDString = try? container.decode(String.self, forKey: .cover_i) {
            cover_i = CoverID(stringValue: coverIDString)
        } else if let coverIDInt = try? container.decode(Int.self, forKey: .cover_i) {
            cover_i = CoverID(intValue: coverIDInt)
        } else {
            cover_i = nil
        }
    }
}

// MARK: - Cover ID

/// Model representing cover ID which can be either String or Int
struct CoverID {
    let stringValue: String
    let intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    var value: String {
        return stringValue
    }
}
