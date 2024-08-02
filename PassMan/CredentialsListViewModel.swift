import Foundation
import CoreData

struct CredentialWrapper: Identifiable {
    fileprivate var credential: Credential
    
    var id: UUID {
        get { credential.id!}
    }
    var username: String {
        get { credential.username!}
    }
    var password: String {
        get { credential.password!}
    }
    var isPasswordVisible: Bool = false
    
    init(credential: Credential) {
        self.credential = credential
    }
}

struct CredentialGroupWrapper: Identifiable {
    fileprivate let credentialGroup: CredentialGroup
    
    var id: UUID {
        get { credentialGroup.id!}
    }
    var resource: String {
        get { credentialGroup.resource!}
    }
    var credentials: [CredentialWrapper]
    
    init(credentialGroup: CredentialGroup) {
        self.credentialGroup = credentialGroup
        credentials = (credentialGroup.credentials?.allObjects as? [Credential] ?? []).map { CredentialWrapper(credential: $0)}
    }
}

class CredentialsListViewModel: ObservableObject {
    @Published var credentialsList: [CredentialGroupWrapper] = []
    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    init() {
        container = NSPersistentContainer(name: "CredentialsModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                // TODO: add proper error handling, show some message to the user or so
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
        fetchCredentialGroups()
        sort()
    }
    
    //TODO rename to addCredential()
    func addCredentialGroup(resource: String, username: String, password: String) {
        var credentialGroup: CredentialGroup?
        var credentialGroupIndex: Int?
        // if such resource already exist - add to it
        for index in credentialsList.indices {
            if credentialsList[index].resource == resource {
                credentialGroup = credentialsList[index].credentialGroup
                credentialGroupIndex = index
                break
            }
        }
        // if there is no such resource - create
        if credentialGroup == nil {
            // add group to Core Data
            credentialGroup = CredentialGroup(context: context)
            credentialGroup!.id = UUID()
            credentialGroup!.resource = resource
            credentialGroup!.timestamp = Date.now
            
            // add group to ViewModel
            credentialsList.append(CredentialGroupWrapper(credentialGroup: credentialGroup!))
            credentialGroupIndex = credentialsList.endIndex - 1
        }
        
        // add credential to Core Data
        let credential: Credential = Credential(context: context)
        credential.id = UUID()
        credential.username = username
        credential.password = password
        credential.timestamp = Date.now
        credential.credentialGroup = credentialGroup!
        
        credentialGroup!.addToCredentials(credential)
        saveContext()
        
        // add credential to ViewModel
        credentialsList[credentialGroupIndex!].credentials.append(CredentialWrapper(credential: credential))
        sort()
    }
    
    func editCredential(credential: CredentialWrapper, username: String, password: String) {
        // need to update the UI because no Publeshed properties will be changed change
        self.objectWillChange.send()
        
        // edit in Core Data
        credential.credential.username = username
        credential.credential.password = password
        saveContext()
        
        sort()
    }
    
    func removeCredentialGroups(atOffsets: IndexSet) {
        // remove from Core Data
        for index in atOffsets {
            if index >= 0 && index < credentialsList.count {
                context.delete(credentialsList[index].credentialGroup)
            }
        }
        saveContext()
        // remove from ViewModel
        credentialsList.remove(atOffsets: atOffsets)
    }
    
    func removeCredentials(credentialGroupIndex: Int, atOffsets: IndexSet) {
        if credentialGroupIndex >= 0 && credentialGroupIndex < credentialsList.count {
            // remove from Core Data
            for index in atOffsets {
                if index >= 0 && index < credentialsList[credentialGroupIndex].credentials.count {
                    context.delete(credentialsList[credentialGroupIndex].credentials[index].credential)
                }
            }
            saveContext()
            // remove from ViewModel
            credentialsList[credentialGroupIndex].credentials.remove(atOffsets: atOffsets)
        }
    }
    
    // TODO: add more criteria for sorting and make a public API for it
    private func sort() {
        credentialsList.sort(by: { $0.credentialGroup.timestamp! < $1.credentialGroup.timestamp!})
        for index in 0..<credentialsList.count {
            credentialsList[index].credentials.sort(by: { $0.credential.timestamp! < $1.credential.timestamp!})
        }
    }
    
    private func fetchCredentialGroups() {
        let fetchRequest: NSFetchRequest<CredentialGroup> = CredentialGroup.fetchRequest()
        do {
            let credentialGroups: [CredentialGroup] = try context.fetch(fetchRequest)
            credentialsList = credentialGroups.map { CredentialGroupWrapper(credentialGroup: $0)}
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
