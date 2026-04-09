import Foundation
import Combine

class ContainerViewModel: ObservableObject {
    @Published var containers: [ContainerRecord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var currentContainer: ContainerRecord?
    
    private let dataStore: DataStore
    private let nfcManager: NFCManager
    
    init(dataStore: DataStore = .shared, nfcManager: NFCManager = .shared) {
        self.dataStore = dataStore
        self.nfcManager = nfcManager
        loadContainers()
    }
    
    func loadContainers() {
        containers = dataStore.fetchAll()
    }
    
    func saveContainer(
        tagID: String,
        foodName: String,
        foodCategory: FoodCategory? = nil,
        dateFrozen: Date,
        notes: String?,
        bestBeforeDate: Date? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            foodCategory: foodCategory,
            dateFrozen: dateFrozen,
            notes: notes,
            bestBeforeDate: bestBeforeDate
        )
        
        guard record.isValid else {
            completion(.failure(DataStoreError.saveFailed(NSError(domain: "Validation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid container data"]))))
            return
        }
        
        do {
            try dataStore.save(record: record)
            loadContainers()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveContainerWithNFC(
        foodName: String,
        foodCategory: FoodCategory? = nil,
        dateFrozen: Date,
        notes: String?,
        bestBeforeDate: Date? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("🔵 ViewModel: saveContainerWithNFC called")
        print("🔵 ViewModel: foodName=\(foodName), bestBeforeDate=\(String(describing: bestBeforeDate))")
        setLoading(true)
        
        let tagID = UUID().uuidString
        let record = ContainerRecord(
            tagID: tagID,
            foodName: foodName,
            foodCategory: foodCategory,
            dateFrozen: dateFrozen,
            notes: notes,
            bestBeforeDate: bestBeforeDate
        )
        
        print("🔵 ViewModel: Created record with tagID=\(tagID)")
        
        guard record.isValid else {
            print("❌ ViewModel: Record validation failed")
            setLoading(false)
            completion(.failure(DataStoreError.saveFailed(NSError(domain: "Validation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid container data"]))))
            return
        }
        
        print("✅ ViewModel: Record is valid, calling nfcManager.writeTag")
        nfcManager.writeTag(record: record) { [weak self] result in
            print("🔵 ViewModel: writeTag callback received with result: \(result)")
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoading(false)
                
                switch result {
                case .success:
                    do {
                        try self.dataStore.save(record: record)
                        self.loadContainers()
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func scanContainer(completion: @escaping (Result<ContainerRecord, Error>) -> Void) {
        let scanRequestTime = Date()
        print("⏱️ ViewModel TIMING: scanContainer called")
        setLoading(true)
        
        nfcManager.readTag { [weak self] result in
            let nfcCallbackTime = Date()
            print("⏱️ ViewModel TIMING: NFC callback received after \(String(format: "%.3f", nfcCallbackTime.timeIntervalSince(scanRequestTime)))s")
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let mainQueueTime = Date()
                print("⏱️ ViewModel TIMING: Main queue block executing after \(String(format: "%.3f", mainQueueTime.timeIntervalSince(nfcCallbackTime)))s")
                self.setLoading(false)
                
                switch result {
                case .success(let tagID):
                    print("🔍 ViewModel: Looking up container with tagID: \(tagID)")
                    
                    if let container = self.dataStore.fetch(byTagID: tagID) {
                        print("✅ ViewModel: Found container - \(container.foodName)")
                        self.currentContainer = container
                        print("⏱️ ViewModel TIMING: About to call completion callback")
                        completion(.success(container))
                        print("⏱️ ViewModel TIMING: Completion callback returned, total time: \(String(format: "%.3f", Date().timeIntervalSince(scanRequestTime)))s")
                    } else {
                        print("❌ ViewModel: Container not found in database for tagID: \(tagID)")
                        let error = NSError(domain: "ContainerViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Container not found for this tag"])
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("❌ ViewModel: NFC read failed - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    func fetchContainer(byTagID tagID: String) -> ContainerRecord? {
        return dataStore.fetch(byTagID: tagID)
    }
    
    func updateContainer(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        print("🔵 ViewModel: updateContainer called with id=\(record.id), foodName=\(record.foodName)")
        guard record.isValid else {
            print("❌ ViewModel: Record validation failed - isValid=false")
            completion(.failure(DataStoreError.updateFailed(NSError(domain: "Validation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid container data"]))))
            return
        }
        
        print("🔵 ViewModel: Record is valid, calling dataStore.update")
        do {
            try dataStore.update(record: record)
            print("✅ ViewModel: dataStore.update succeeded, reloading containers")
            loadContainers()
            completion(.success(()))
        } catch {
            print("❌ ViewModel: dataStore.update failed - \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func clearContainer(tagID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try dataStore.clearContainer(tagID: tagID)
            loadContainers()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteContainer(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try dataStore.delete(record: record)
            loadContainers()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func setError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
    }
    
    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            self.isLoading = loading
        }
    }
}
