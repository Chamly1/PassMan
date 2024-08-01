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
            credentialGroup!.timestamp = Date.now
        }
        
        let credential: Credential = Credential(context: context)
        credential.id = UUID()
        credential.username = username
        credential.password = password
        credential.timestamp = Date.now
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
    
    func removeCredentialGroups(atOffsets: IndexSet) {
        for index in atOffsets {
            if index >= 0 && index < credentialsList.count {
                context.delete(credentialsList[index].credentialGroup)
            }
        }
        saveContext()
        fetchCredentialGroups()
    }
    
    func removeCredentials(credentialGroupIndex: Int, atOffsets: IndexSet) {
        if credentialGroupIndex >= 0 && credentialGroupIndex < credentialsList.count {
            for index in atOffsets {
                if index >= 0 && index < credentialsList[credentialGroupIndex].credentials.count {
                    context.delete(credentialsList[credentialGroupIndex].credentials[index].credential)
                }
            }
        }
        saveContext()
        fetchCredentialGroups()
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
            credentialGroups = try context.fetch(fetchRequest)
            credentialsList = credentialGroups.map { CredentialGroupWrapper(credentialGroup: $0)}
        } catch {
            // TODO: add proper error handling, show some message to the user or so
            print("Failed to fetch credentialGroups: \(error)")
        }
        sort()
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
