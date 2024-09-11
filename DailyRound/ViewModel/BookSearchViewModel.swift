import Foundation
import SwiftUI
import Combine

// MARK: - ViewModel Definition

class BookSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var searchQuery: String = ""
    @Published var books: [Book] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private var currentOffset = 0
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    
    func fetchBooks(refreshing: Bool = false) {
        guard !searchQuery.isEmpty else { return }
        
        if refreshing {
            currentOffset = 0
            books.removeAll()
        }
        
        guard let url = URL(string: makeUrlString()) else { return }
        
        isLoading = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: BookSearchResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error fetching books: \(error)")
                }
                self?.isLoading = false
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                let newBooks = response.docs.map { doc in
                    Book(
                        id: doc.key,
                        title: doc.title,
                        ratingAverage: doc.ratings_average ?? 0.0,
                        ratingCount: doc.ratings_count ?? 0,
                        coverID: doc.cover_i?.value ?? ""
                    )
                }
                
                self.books.append(contentsOf: newBooks)
                self.currentOffset += newBooks.count
            }
            .store(in: &cancellables)
    }
    
    func sortBooksByTitle() {
        books.sort { $0.title < $1.title }
    }
    
    func sortBooksByRating() {
        books.sort { $0.ratingAverage > $1.ratingAverage }
    }
    
    func sortBooksByHits() {
        books.sort { $0.ratingCount > $1.ratingCount }
    }
    
    // MARK: - Private Methods
    
    private func makeUrlString() -> String {
        let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return "https://openlibrary.org/search.json?title=\(encodedQuery)&limit=10&offset=\(currentOffset)"
    }
}
