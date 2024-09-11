import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = BookSearchViewModel()
    @StateObject private var loginViewModel = LoginViewModel()
    @StateObject private var bookmarkViewModel = BookmarkViewModel()
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var selectedSortOption: String? = nil
    @State private var showBookmarkAlert = false
    @State private var bookmarkedBookTitle = ""
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        VStack {
            headerView
            searchAndSortView
            bookListView
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                //app logo and name 
                HStack {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    Text("MedBook")
                        .font(.title)
                        .bold()
                        .frame(width: 130)
                }
            }
            
           ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    //bookmark btn
                    NavigationLink(destination: BookmarkView(bookmarks: bookmarkViewModel.bookmarks)
                        .environmentObject(bookmarkViewModel)) {
                        Image(systemName: "bookmark.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }
                    //logout btn
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                            .tint(Color.red)
                    }
                    .alert(isPresented: $showLogoutConfirmation) {
                        Alert(
                            title: Text("Confirm Logout"),
                            message: Text("Are you sure you want to log out?"),
                            primaryButton: .destructive(Text("Logout")) {
                                loginViewModel.logout()
                                presentationMode.wrappedValue.dismiss()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
        .alert(isPresented: $showBookmarkAlert) {
            Alert(
                title: Text("Bookmarked"),
                message: Text("\(bookmarkedBookTitle) has been added to your bookmarks."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            viewModel.fetchBooks()
            bookmarkViewModel.loadBookmarks()
        }
        .refreshable {
            viewModel.fetchBooks(refreshing: true)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Which topic interests you today?")
                .font(.title)
                .lineLimit(2)
                .padding([.leading, .top])
                .frame(width: 300, alignment: .leading)
            Spacer()
        }
    }
    
    private var searchAndSortView: some View {
        VStack {
            TextField("Search for books", text: $viewModel.searchQuery)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                .onChange(of: viewModel.searchQuery) { newValue in
                    if newValue.count >= 3 {
                        viewModel.fetchBooks()
                    }
                }
            
            sortOptionsView
                .padding()
        }
    }
    
    private var sortOptionsView: some View {
        HStack {
            Text("Sort By: ")
            
            sortButton(title: "Title", sortAction: viewModel.sortBooksByTitle)
            sortButton(title: "Rating", sortAction: viewModel.sortBooksByRating)
            sortButton(title: "Hits", sortAction: viewModel.sortBooksByHits)
        }
    }
    
    private func sortButton(title: String, sortAction: @escaping () -> Void) -> some View {
        Button(action: {
            sortAction()
            selectedSortOption = title
        }) {
            Text(title)
                .foregroundColor(selectedSortOption == title ? .black : .secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedSortOption == title ? Color.gray : Color.clear)
                .cornerRadius(8)
        }
    }
    
    private var bookListView: some View {
        List(viewModel.books) { book in
            HStack {
                AsyncImage(url: URL(string: "https://covers.openlibrary.org/b/id/\(book.coverID)-M.jpg")) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 90)
                } placeholder: {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 90)
                }
                
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.headline)
                        .padding(.bottom)
                    
                    HStack {
                        ratingView(rating: book.ratingAverage, count: book.ratingCount)
                        Spacer()
                        hitsView(count: book.ratingCount)
                    }
                }
            }
            .swipeActions(edge: .trailing) {
                bookmarkButton(book: book)
            }
        }
    }
    
    private func ratingView(rating: Double, count: Int) -> some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text("Rating: \(String(format: "%.1f", rating))")
                .font(.subheadline)
        }
    }
    
    private func hitsView(count: Int) -> some View {
        HStack {
            Image(systemName: "square.split.bottomrightquarter")
                .foregroundColor(.yellow)
            Text("Hits: \(count)")
                .font(.subheadline)
        }
    }
    
    private func bookmarkButton(book: Book) -> some View {
        Button(action: {
            let newBookmark = Bookmark(
                id: book.id,
                title: book.title,
                ratingAverage: book.ratingAverage,
                ratingCount: book.ratingCount,
                coverID: book.coverID
            )
            
            if LoginViewModel.currentUserId != nil {
                bookmarkViewModel.addBookmark(newBookmark)
                bookmarkedBookTitle = book.title
                showBookmarkAlert = true
            }
        }) {
            Label("Bookmark", systemImage: "bookmark")
                .tint(Color.yellow)
        }
    }
}

#Preview {
    HomeView()
}
