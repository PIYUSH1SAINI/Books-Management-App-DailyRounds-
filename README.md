Book Search and Management App

Overview

This mobile application is designed to help users sign up, log in, search for books, and manage their bookmarks. The app integrates with various APIs to fetch book data and country information and utilizes a local database to store user credentials and bookmarked books.
Features

1. Landing Screen
Call-to-Action (CTA) Buttons:
Signup: Directs users to the Signup Screen.
Login: Directs users to the Login Screen.
2. Signup Screen
Email Input:
Validation: Ensures the email format is correct.
Password Input:
Validation:
Minimum 8 characters
At least 1 uppercase letter
At least 1 special character
Country Picker:
API for Country Data: Utilizes the First API to load country information and store it in a local database.
Default Country Selection: Uses the IPinfo API to set the default country based on the user's IP address.
Signup Process:
Validation: Checks email and password against validation rules.
Local Storage: Saves user information in a local database.
Navigation: Redirects users to the Home Screen upon successful signup.
3. Login Screen
Email and Password Input:
Validation: Checks credentials against the local database.
Authentication: Validates the entered credentials and allows access if correct.
Session Management:
Persistent Login: Maintains session so that users land on the Home Screen after reopening the app until they log out.
4. Home Screen
Search Bar: Allows users to search for books by title.
Book Listing:
API: Fetches book data from the Open Library API.
Parameters:
title: Search query
limit: Number of results
offset: Skips initial results
Cover Image: Fetches cover images using Open Library Cover Image API.
Sorting: Manual sorting of search results by title, average rating, or hits.
Pagination: Loads more results when the end of the list is reached.
Table View Cell Modifications:
Bookmark Button: Added to each book result.
Bookmark Action: Stores the book in the local database when bookmarked.
5. Bookmarked Screen
Display: Shows bookmarked books in a TableView using the same cell design as the Home Screen.
Remove Bookmark: Allows users to unbookmark a book from the Bookmarked Screen.
Findings

Default Country API:
Issue: The IPinfo API was used instead of IP-API due to security concerns (HTTP vs. HTTPS). The app crashed with HTTP-based APIs.
Bug Reports

Back Button Bug:
Issue: The back button appears when logging in or signing up, which should not be present.
Logout Issue:
Issue: After logging out, the app does not return to the landing page; it remains on the Home Screen until manually restarted.
Country Picker Update:
Issue: The country picker does not update its value correctly due to discrepancies between the country codes used by the IPinfo API and the First API.
Contribution

Contributions to improve the app are welcome. Please follow the standard GitHub workflow for issues and pull requests. Ensure that any new code adheres to the existing coding standards and includes appropriate documentation.
Thank you for your interest in contributing to the Book Search and Management App!
