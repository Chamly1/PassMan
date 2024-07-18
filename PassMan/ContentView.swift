import SwiftUI

struct ContentView: View {
    var body: some View {
        CredentialsListView()
    }
}

#Preview {
    ContentView().environmentObject(CredentialsListViewModel())
}
