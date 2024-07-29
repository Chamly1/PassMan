import Foundation
import CoreData

//struct Credential: Identifiable {
//    let id = UUID()
//    var username: String
//    var password: String
//    var isPasswordVisible: Bool = false
//}
//
//struct CredentialGroup: Identifiable {
//    let id = UUID()
//    let resource: String
//    var credentials: [Credential]
//}

class CredentialsListViewModel: ObservableObject {
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext {
        return container.viewContext
    }
    @Published var credentialsList: [CredentialGroup] = []
    
    init() {
        container = NSPersistentContainer(name: "CredentialsModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                // TODO: add proper error handling, show some message to the user or so
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        fetchCredentialGroups()
    }
    
    //TODO rename to addCredential()
    func addCredentialGroup(resource: String, username: String, password: String) {
        var credentialGroup: CredentialGroup?
        // if such resource already exist - add to it
        for index in credentialsList.indices {
            if credentialsList[index].resource == resource {
                credentialGroup = credentialsList[index]
                break
            }
        }
        // if there is no such resource - create
        if credentialGroup == nil {
            credentialGroup = CredentialGroup(context: context)
            credentialGroup!.id = UUID()
            credentialGroup!.resource = resource
        }
        
        let credential: Credential = Credential(context: context)
        credential.id = UUID()
        credential.username = username
        credential.password = password
        credential.credentialGroup = credentialGroup!
        
        credentialGroup!.addToCredentials(credential)
        
        saveContext()
        fetchCredentialGroups()
    }
    
    func editCredential(credential: Credential, username: String, password: String) {
        credential.username = username
        credential.password = password
        saveContext()
        fetchCredentialGroups()
    }
    
    private func fetchCredentialGroups() {
        let fetchRequest: NSFetchRequest<CredentialGroup> = CredentialGroup.fetchRequest()
        do {
            credentialsList = try context.fetch(fetchRequest)
        } catch {
            // TODO: add proper error handling, show some message to the user or so
            print("Failed to fetch credentialGroups: \(error)")
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // TODO: add proper error handling, show some message to the user or so
                print("Failed to save context: \(error)")
            }
        }
    }
}
