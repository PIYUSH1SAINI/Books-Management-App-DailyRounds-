import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var viewModel: BookmarkViewModel
    var bookmarks: [Bookmark]

    var body: some View {
        VStack {
            if bookmarks.isEmpty {
                emptyStateView
            } else {
                bookmarkListView
            }
        }
        .navigationTitle("Bookmarks")
    }
    
    private var emptyStateView: some View {
        Text("No bookmarks found.")
            .font(.title2)
            .foregroundColor(.gray)
            .padding()
    }
    
    private var bookmarkListView: some View {
        List(bookmarks) { bookmark in
            HStack {
                bookCoverImage(for: bookmark)
                
                VStack(alignment: .leading) {
                    Text(bookmark.title)
                        .font(.headline)
                        .padding(.bottom)
                    
                    bookDetails(for: bookmark)
                }
            }
            .swipeActions {
                deleteButton(for: bookmark)
            }
        }
    }
    
    private func bookCoverImage(for bookmark: Bookmark) -> some View {
        AsyncImage(url: URL(string: "https://covers.openlibrary.org/b/id/\(bookmark.coverID)-M.jpg")) { image in
            image.resizable()
                .scaledToFit()
                .frame(width: 60, height: 90)
        } placeholder: {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 90)
        }
    }
    
    private func bookDetails(for bookmark: Bookmark) -> some View {
        HStack {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Rating: \(String(format: "%.1f", bookmark.ratingAverage))")
                    .font(.subheadline)
            }
            Spacer()
            HStack {
                Image(systemName: "square.split.bottomrightquarter")
                    .foregroundColor(.yellow)
                
                Text("Hits: \(bookmark.ratingCount)")
                    .font(.subheadline)
            }
        }
    }
    
    private func deleteButton(for bookmark: Bookmark) -> some View {
        Button(role: .destructive) {
            viewModel.removeBookmark(bookmark)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview {
    BookmarkView(bookmarks: []) // Add sample bookmarks for preview if needed
}
