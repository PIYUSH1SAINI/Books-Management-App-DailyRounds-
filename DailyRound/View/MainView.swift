import SwiftUI

struct MainView: View {
    @StateObject private var loginViewModel = LoginViewModel()

    var body: some View {
        NavigationView {
            Group {
                if loginViewModel.isLoggedIn {
                    HomeView()
                } else {
                    LandingScreen()
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
