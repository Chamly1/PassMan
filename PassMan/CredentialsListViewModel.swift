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
    
    @UserDefaultEnum(key: "groupsSortOption", defaultValue: .dateCreated) var groupsSortOption: SortingOptions {
        didSet {
            self.objectWillChange.send()
            sortGroups()
        }
    }
    @UserDefaultEnum(key: "groupsSortOrder", defaultValue: .ascending) var groupsSortOrder: SortingOrders {
        didSet {
            self.objectWillChange.send()
            sortGroups()
        }
    }
    @UserDefaultEnum(key: "credentialsSortOption", defaultValue: .dateCreated) var credentialsSortOption: SortingOptions {
        didSet {
            self.objectWillChange.send()
            sortCredentials()
        }
    }
    @UserDefaultEnum(key: "credentialsSortOrder", defaultValue: .ascending) var credentialsSortOrder: SortingOrders {
        didSet {
            self.objectWillChange.send()
            sortCredentials()
        }
    }
    
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
        sortGroups()
        sortCredentials()
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
            credentialGroup!.dateCreated = Date.now
            
            // add group to ViewModel
            credentialsList.append(CredentialGroupWrapper(credentialGroup: credentialGroup!))
            credentialGroupIndex = credentialsList.endIndex - 1
        }
        
        // add credential to Core Data
        let credential: Credential = Credential(context: context)
        credential.id = UUID()
        credential.username = username
        credential.password = password
        credential.dateCreated = Date.now
        credential.dateEdited = Date.now
        credential.credentialGroup = credentialGroup!
        
        credentialGroup!.addToCredentials(credential)
        credentialGroup!.dateEdited = Date.now
        saveContext()
        
        // add credential to ViewModel
        credentialsList[credentialGroupIndex!].credentials.append(CredentialWrapper(credential: credential))
        sortGroups()
        sortCredentials()
    }
    
    func editCredential(credential: CredentialWrapper, username: String, password: String) {
        // need to update the UI because no Publeshed properties will be changed change
        self.objectWillChange.send()
        
        // edit in Core Data
        credential.credential.username = username
        credential.credential.password = password
        credential.credential.dateEdited = Date.now
        credential.credential.credentialGroup!.dateEdited = Date.now
        saveContext()
        
        sortGroups()
        sortCredentials()
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
                    credentialsList[credentialGroupIndex].credentialGroup.dateEdited = Date.now
                }
            }
            saveContext()
            // remove from ViewModel
            credentialsList[credentialGroupIndex].credentials.remove(atOffsets: atOffsets)
            sortGroups()
        }
    }
    
    private func sortGroups() {
        switch groupsSortOption {
        case .dateCreated:
            credentialsList.sort(by: { compare($0.credentialGroup.dateCreated!, $1.credentialGroup.dateCreated!, order: groupsSortOrder)})
        case .dateEdited:
            credentialsList.sort(by: { compare($0.credentialGroup.dateEdited!, $1.credentialGroup.dateEdited!, order: groupsSortOrder)})
        case .title:
            credentialsList.sort(by: { compare($0.credentialGroup.resource!, $1.credentialGroup.resource!, order: groupsSortOrder)})
        }
    }
    
    private func sortCredentials() {
        for index in 0..<credentialsList.count {
            switch groupsSortOption {
            case .dateCreated:
                credentialsList[index].credentials.sort(by: { compare($0.credential.dateCreated!, $1.credential.dateCreated!, order: groupsSortOrder)})
            case .dateEdited:
                credentialsList[index].credentials.sort(by: { compare($0.credential.dateEdited!, $1.credential.dateEdited!, order: groupsSortOrder)})
            case .title:
                credentialsList[index].credentials.sort(by: { compare($0.credential.username!, $1.credential.username!, order: groupsSortOrder)})
            }
        }
    }
    
    private func compare<T: Comparable>(_ first: T, _ second: T, order: SortingOrders) -> Bool {
        switch order {
        case .ascending:
            return first <= second
        case .descending:
            return first > second
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
