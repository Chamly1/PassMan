import Foundation
import CoreData

class CredentialWrapper: Identifiable {
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

class CredentialGroupWrapper: Identifiable {
    fileprivate let credentialGroup: CredentialGroup
    
    var id: UUID {
        get { credentialGroup.id!}
    }
    var resource: String {
        get { credentialGroup.resource!}
    }
    var credentials: [CredentialWrapper] {
        (credentialGroup.credentials?.allObjects as? [Credential] ?? []).map { CredentialWrapper(credential: $0)}
    }
    
    init(credentialGroup: CredentialGroup) {
        self.credentialGroup = credentialGroup
    }
}

class CredentialsListViewModel: ObservableObject {
    @Published var credentialsList: [CredentialGroupWrapper] = []
    private var credentialGroups: [CredentialGroup] = []
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
    }
    
    //TODO rename to addCredential()
    func addCredentialGroup(resource: String, username: String, password: String) {
        var credentialGroup: CredentialGroup?
        // if such resource already exist - add to it
        for index in credentialGroups.indices {
            if credentialGroups[index].resource == resource {
                credentialGroup = credentialGroups[index]
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
    
    func editCredential(credential: CredentialWrapper, username: String, password: String) {
        credential.credential.username = username
        credential.credential.password = password
        saveContext()
        fetchCredentialGroups()
    }
    
    private func fetchCredentialGroups() {
        let fetchRequest: NSFetchRequest<CredentialGroup> = CredentialGroup.fetchRequest()
        do {
            credentialGroups = try context.fetch(fetchRequest)
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
