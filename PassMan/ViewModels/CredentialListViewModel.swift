//
//  CredentialListViewModel.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 12.09.2024.
//

import Foundation

class CredentialListViewModel: ObservableObject {
    @Published var isDeleteConfirmationShown: Bool = false
    private var credentialsViewModel: CredentialsViewModel?
    private var credentialGroupToDeleteIndex: Int?
    private var credentialToDeleteIndexSet: IndexSet?
    
    func prepareDeleteAndShowConfirmation(credentialsViewModel: CredentialsViewModel, credentialGroupIndex: Int, atOffsets: IndexSet) {
        self.credentialsViewModel = credentialsViewModel
        self.credentialGroupToDeleteIndex = credentialGroupIndex
        self.credentialToDeleteIndexSet = atOffsets
        self.isDeleteConfirmationShown = true
    }
    
    func performDelete(dismiss: () -> Void) {
        if let credentialsViewModel = credentialsViewModel,
           let credentialGroupIndex = credentialGroupToDeleteIndex,
           let credentialIndexSet = credentialToDeleteIndexSet {
            credentialsViewModel.removeCredentials(credentialGroupIndex: credentialGroupIndex, atOffsets: credentialIndexSet)
            if credentialsViewModel.credentialGroups[credentialGroupIndex].credentials.count == 0 {
                credentialsViewModel.removeCredentialGroups(atOffsets: IndexSet(integer: credentialGroupIndex))
                dismiss()
            }
        }
    }
}
