import SwiftUI

struct ContentView: View {
    var body: some View {
        PasswordsListView()
    }
}

#Preview {
    ContentView().environmentObject(PasswordsListViewModel())
}
