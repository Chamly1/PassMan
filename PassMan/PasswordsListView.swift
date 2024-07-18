import SwiftUI

struct PasswordsListView: View {
    @EnvironmentObject var passwordsListViewModel: PasswordsListViewModel
    
    var body: some View {
        List {
            ForEach(passwordsListViewModel.passwordsList, id: \.self) { pass in
                Text(pass)
            }
        }
    }
}

#Preview {
    PasswordsListView().environmentObject(PasswordsListViewModel())
}
