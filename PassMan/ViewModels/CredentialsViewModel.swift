import Foundation
import CoreData
import CryptoKit

class CredentialWrapper: Identifiable {
    fileprivate var credential: Credential
    
    let id: UUID
    var username: String
    var password: String
    var isPasswordVisible: Bool = false
    
    init(credential: Credential, encryptionService: EncryptionService) throws {
        self.credential = credential
        self.id = credential.id!
        
        username = try encryptionService.decrypt(credential.username!)
        password = try encryptionService.decrypt(credential.password!)
    }
}

class CredentialGroupWrapper: Identifiable {
    fileprivate let credentialGroup: CredentialGroup
    
    let id: UUID
    var resource: String
    var credentials: [CredentialWrapper]
    
    init(credentialGroup: CredentialGroup, encryptionService: EncryptionService) throws {
        self.credentialGroup = credentialGroup
        self.id = credentialGroup.id!
        
        resource = try encryptionService.decrypt(credentialGroup.resource!)
        
        credentials = try (credentialGroup.credentials?.allObjects as? [Credential] ?? []).map { try CredentialWrapper(credential: $0, encryptionService: encryptionService)}
    }
}

class CredentialsViewModel: ObservableObject {
    @Published var credentialGroups: [CredentialGroupWrapper] = []
    @Published var isEncryptionKeySet: Bool = false
    
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
    private var encryptionService: EncryptionService?
    
    init() {
        container = NSPersistentContainer(name: "CredentialsModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                // TODO: add proper error handling, show some message to the user or so
                fatalError("Unresolved error \(error), \(error.localizedDescription)")
            }
        }
    }
    
    func setEncryptionKey(key: SymmetricKey) throws {
        encryptionService = EncryptionService(key: key)
        
        try fetchAndDecryptCredentialGroups()
        sortGroups()
        sortCredentials()
        
        isEncryptionKeySet = true
    }
    
    func addCredential(resource: String, username: String, password: String) throws {
        let encryptionService = try ensureEncryptionService()
        
        var credentialGroup: CredentialGroup?
        var credentialGroupIndex: Int?
        // if such resource already exist - add to it
        for index in credentialGroups.indices {
            if credentialGroups[index].resource == resource {
                credentialGroup = credentialGroups[index].credentialGroup
                credentialGroupIndex = index
                break
            }
        }
        // if there is no such resource - create
        if credentialGroup == nil {
            // add group to Core Data
            credentialGroup = CredentialGroup(context: context)
            credentialGroup!.id = UUID()
            credentialGroup!.resource = try encryptionService.encrypt(resource)
            credentialGroup!.dateCreated = Date.now
            
            // add group to ViewModel
            credentialGroups.append(try CredentialGroupWrapper(credentialGroup: credentialGroup!, encryptionService: encryptionService))
            credentialGroupIndex = credentialGroups.endIndex - 1
        }
        
        // add credential to Core Data
        let credential: Credential = Credential(context: context)
        credential.id = UUID()
        credential.username = try encryptionService.encrypt(username)
        credential.password = try encryptionService.encrypt(password)
        credential.dateCreated = Date.now
        credential.dateEdited = Date.now
        credential.credentialGroup = credentialGroup!
        
        credentialGroup!.addToCredentials(credential)
        credentialGroup!.dateEdited = Date.now
        saveContext()
        
        // add credential to ViewModel
        credentialGroups[credentialGroupIndex!].credentials.append(try CredentialWrapper(credential: credential, encryptionService: encryptionService))
        sortGroups()
        sortCredentials()
    }
    
    func editCredential(credential: CredentialWrapper, username: String, password: String) throws {
        // need to update the UI because no Publeshed properties will be changed change
        self.objectWillChange.send()
        
        let encryptionService = try ensureEncryptionService()
        
        var wasEdited = false
        // edit in Core Data
        if credential.username != username {
            credential.credential.username = try encryptionService.encrypt(username)
            credential.username = username
            wasEdited = true
        }
        if credential.password != password {
            credential.credential.password = try encryptionService.encrypt(password)
            credential.password = password
            wasEdited = true
        }
        
        if wasEdited {
            credential.credential.dateEdited = Date.now
            credential.credential.credentialGroup!.dateEdited = Date.now
            saveContext()
            
            sortGroups()
            sortCredentials()
        }
    }
    
    func removeCredentialGroups(atOffsets: IndexSet) {
        // remove from Core Data
        for index in atOffsets {
            if index >= 0 && index < credentialGroups.count {
                context.delete(credentialGroups[index].credentialGroup)
            }
        }
        saveContext()
        // remove from ViewModel
        credentialGroups.remove(atOffsets: atOffsets)
    }
    
    func removeCredentials(credentialGroupIndex: Int, atOffsets: IndexSet) {
        if credentialGroupIndex >= 0 && credentialGroupIndex < credentialGroups.count {
            // remove from Core Data
            for index in atOffsets {
                if index >= 0 && index < credentialGroups[credentialGroupIndex].credentials.count {
                    context.delete(credentialGroups[credentialGroupIndex].credentials[index].credential)
                    credentialGroups[credentialGroupIndex].credentialGroup.dateEdited = Date.now
                }
            }
            saveContext()
            // remove from ViewModel
            credentialGroups[credentialGroupIndex].credentials.remove(atOffsets: atOffsets)
            sortGroups()
        }
    }
    
    private func sortGroups() {
        switch groupsSortOption {
        case .dateCreated:
            credentialGroups.sort(by: { compare($0.credentialGroup.dateCreated!, $1.credentialGroup.dateCreated!, order: groupsSortOrder)})
        case .dateEdited:
            credentialGroups.sort(by: { compare($0.credentialGroup.dateEdited!, $1.credentialGroup.dateEdited!, order: groupsSortOrder)})
        case .title:
            credentialGroups.sort(by: { compare($0.resource, $1.resource, order: groupsSortOrder)})
        }
    }
    
    private func sortCredentials() {
        for index in 0..<credentialGroups.count {
            switch credentialsSortOption {
            case .dateCreated:
                credentialGroups[index].credentials.sort(by: { compare($0.credential.dateCreated!, $1.credential.dateCreated!, order: credentialsSortOrder)})
            case .dateEdited:
                credentialGroups[index].credentials.sort(by: { compare($0.credential.dateEdited!, $1.credential.dateEdited!, order: credentialsSortOrder)})
            case .title:
                credentialGroups[index].credentials.sort(by: { compare($0.username, $1.username, order: credentialsSortOrder)})
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
    
    private func fetchAndDecryptCredentialGroups() throws {
        let encryptionService = try ensureEncryptionService()
        
        let fetchRequest: NSFetchRequest<CredentialGroup> = CredentialGroup.fetchRequest()
        let rawCredentialGroups: [CredentialGroup] = try context.fetch(fetchRequest)
        credentialGroups = try rawCredentialGroups.map { try CredentialGroupWrapper(credentialGroup: $0, encryptionService: encryptionService)}
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
    
    private func ensureEncryptionService() throws -> EncryptionService {
        guard let encryptionService = self.encryptionService else {
            throw PassManError.noKey
        }
        
        return encryptionService
    }
}
