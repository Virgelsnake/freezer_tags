import Foundation
import CoreNFC

enum NFCOperation {
    case read
    case write(ContainerRecord)
}

class NFCManager: NSObject, ObservableObject {
    private var session: NFCNDEFReaderSession?
    private var operation: NFCOperation?
    private var readCompletion: ((Result<String, Error>) -> Void)?
    private var writeCompletion: ((Result<Void, Error>) -> Void)?
    private var lastSessionInvalidationTime: Date?
    private var isSessionActive = false
    private var lastSessionWasUserCancelled = false
    private var isStartingSession = false
    private var readRetryCount = 0
    private let maxReadRetries = 1
    
    // Timing tracking
    private var scanStartTime: Date?
    private var tagDetectedTime: Date?
    private var readCompleteTime: Date?
    
    /// Minimum time to wait between session invalidation and new session creation
    /// NFC hardware needs time to fully release the previous session
    private let minimumSessionGap: TimeInterval = 1.0
    
    /// Longer cooldown needed after user cancellation or errors
    /// The NFC hardware takes longer to release in these scenarios
    private let extendedSessionGap: TimeInterval = 2.0
    
    @Published var isScanning = false
    @Published var sessionFullyDismissed = false
    
    static let shared = NFCManager()
    
    private override init() {
        super.init()
    }
    
    /// Ensures sufficient time has passed since last session invalidation
    private func waitForSessionCooldown(completion: @escaping () -> Void) {
        guard let lastInvalidation = lastSessionInvalidationTime else {
            completion()
            return
        }
        
        let elapsed = Date().timeIntervalSince(lastInvalidation)
        let requiredGap = lastSessionWasUserCancelled ? extendedSessionGap : minimumSessionGap
        let remainingWait = requiredGap - elapsed
        
        if remainingWait > 0 {
            print("⏳ NFC: Waiting \(String(format: "%.2f", remainingWait))s for session cooldown (extended: \(lastSessionWasUserCancelled))...")
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingWait) {
                completion()
            }
        } else {
            completion()
        }
    }
    
    func readTag(completion: @escaping (Result<String, Error>) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(NFCError.unsupportedTag))
            return
        }
        
        // Prevent concurrent session starts
        guard !isStartingSession else {
            print("⚠️ NFC: Already starting a session, ignoring duplicate request")
            return
        }
        
        // Ensure any previous session is fully cleaned up
        if session != nil || isSessionActive {
            print("⚠️ NFC: Previous session still exists, cleaning up...")
            session?.invalidate()
            session = nil
            isSessionActive = false
            // Record invalidation time now so cooldown applies
            lastSessionInvalidationTime = Date()
            lastSessionWasUserCancelled = true  // Force extended cooldown
        }
        
        isStartingSession = true
        
        // Wait for session cooldown before starting new session
        waitForSessionCooldown { [weak self] in
            guard let self = self else { return }
            
            print("🚀 NFC: Starting new read session")
            self.scanStartTime = Date()
            self.tagDetectedTime = nil
            self.readCompleteTime = nil
            self.lastSessionWasUserCancelled = false  // Reset flag for new session
            self.readRetryCount = 0  // Reset retry count
            self.sessionFullyDismissed = false  // Reset dismissal flag
            self.readCompletion = completion
            self.operation = .read
            
            self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            self.session?.alertMessage = "Hold your iPhone near the container tag"
            self.session?.begin()
            
            self.isScanning = true
            self.isSessionActive = true
            self.isStartingSession = false
        }
    }
    
    func writeTag(record: ContainerRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion(.failure(NFCError.unsupportedTag))
            return
        }
        
        // Prevent concurrent session starts
        guard !isStartingSession else {
            print("⚠️ NFC: Already starting a session, ignoring duplicate request")
            return
        }
        
        // Ensure any previous session is fully cleaned up
        if session != nil || isSessionActive {
            print("⚠️ NFC: Previous session still exists, cleaning up...")
            session?.invalidate()
            session = nil
            isSessionActive = false
            // Record invalidation time now so cooldown applies
            lastSessionInvalidationTime = Date()
            lastSessionWasUserCancelled = true  // Force extended cooldown
        }
        
        isStartingSession = true
        
        // Wait for session cooldown before starting new session
        waitForSessionCooldown { [weak self] in
            guard let self = self else { return }
            
            print("🚀 NFC: Starting new write session")
            self.lastSessionWasUserCancelled = false  // Reset flag for new session
            self.writeCompletion = completion
            self.operation = .write(record)
            
            self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            self.session?.alertMessage = "Hold your iPhone near the tag to write container information"
            self.session?.begin()
            
            self.isScanning = true
            self.isSessionActive = true
            self.isStartingSession = false
        }
    }
    
    private func createNDEFPayload(from record: ContainerRecord) -> NFCNDEFPayload? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        guard let jsonData = try? encoder.encode(record) else {
            print("❌ NFC: Failed to encode ContainerRecord to JSON")
            return nil
        }
        
        print("📏 NFC: JSON payload size: \(jsonData.count) bytes")
        
        // Use .media format for custom JSON data, not .nfcWellKnown
        // .nfcWellKnown is for standard types (T=text, U=URI, etc.)
        // .media is for MIME type payloads like application/json
        let payload = NFCNDEFPayload(
            format: .media,
            type: "application/json".data(using: .utf8)!,
            identifier: Data(),
            payload: jsonData
        )
        
        print("📦 NFC: NDEF payload created successfully")
        return payload
    }
    
    private func parseContainerRecord(from payload: NFCNDEFPayload) -> String? {
        guard let payloadString = String(data: payload.payload, encoding: .utf8) else {
            print("❌ NFC: Failed to decode payload as UTF-8 string")
            return nil
        }
        
        print("🔍 NFC: Parsing payload string: \(payloadString.prefix(100))...")
        
        guard let jsonData = payloadString.data(using: .utf8) else {
            print("❌ NFC: Failed to convert string back to data")
            return payloadString
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let record = try decoder.decode(ContainerRecord.self, from: jsonData)
            print("✅ NFC: Successfully decoded ContainerRecord, tagID: \(record.tagID)")
            return record.tagID
        } catch {
            print("❌ NFC: Failed to decode JSON - \(error.localizedDescription)")
            print("❌ NFC: Returning raw payload string as fallback")
            return payloadString
        }
    }
}

extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("✅ NFC: Session became active")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let operation = self.operation else { return }
        
        switch operation {
        case .read:
            handleReadOperation(messages: messages, session: session)
        case .write:
            break
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        tagDetectedTime = Date()
        let timeSinceStart = tagDetectedTime!.timeIntervalSince(scanStartTime ?? Date())
        print("📱 NFC: Detected \(tags.count) tag(s) [+\(String(format: "%.3f", timeSinceStart))s]")
        
        guard let operation = self.operation else {
            print("⚠️ NFC: No operation set")
            return
        }
        
        if tags.count > 1 {
            print("⚠️ NFC: Multiple tags detected")
            session.alertMessage = "Multiple tags detected. Please remove extra tags."
            session.invalidate(errorMessage: NFCError.multipleTagsDetected.localizedDescription)
            
            switch operation {
            case .read:
                readCompletion?(.failure(NFCError.multipleTagsDetected))
            case .write:
                writeCompletion?(.failure(NFCError.multipleTagsDetected))
            }
            isScanning = false
            return
        }
        
        guard let tag = tags.first else {
            print("❌ NFC: No tag found in array")
            session.invalidate(errorMessage: NFCError.tagNotFound.localizedDescription)
            
            switch operation {
            case .read:
                readCompletion?(.failure(NFCError.tagNotFound))
            case .write:
                writeCompletion?(.failure(NFCError.tagNotFound))
            }
            isScanning = false
            return
        }
        
        print("🔗 NFC: Connecting to tag...")
        session.connect(to: tag) { error in
            if let error = error {
                print("❌ NFC: Connection failed - \(error.localizedDescription)")
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                
                switch operation {
                case .read:
                    self.readCompletion?(.failure(NFCError.readFailed))
                case .write:
                    self.writeCompletion?(.failure(NFCError.writeFailed))
                }
                self.isScanning = false
                return
            }
            
            print("✅ NFC: Connected to tag successfully")
            
            switch operation {
            case .read:
                self.performRead(tag: tag, session: session)
            case .write(let record):
                self.performWrite(tag: tag, record: record, session: session)
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("🛑 NFC: didInvalidateWithError called")
        print("🛑 NFC: Current operation: \(String(describing: self.operation))")
        
        DispatchQueue.main.async {
            self.isScanning = false
        }
        
        if let readerError = error as? NFCReaderError {
            // Log detailed error information for debugging
            print("NFC Session Error - Code: \(readerError.code.rawValue), Description: \(readerError.localizedDescription)")
            print("🛑 NFC: Error type: NFCReaderError")
            
            switch readerError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                // Code 200 can mean two things:
                // 1. User actually tapped Cancel button
                // 2. We called session.invalidate() programmatically (after success)
                // Only call completion handlers if they haven't been called yet
                print("🛑 NFC: Session cancelled - checking if completion handlers still exist")
                
                // Check if this was a true user cancellation (handlers still exist)
                let wasUserCancellation = self.readCompletion != nil || self.writeCompletion != nil
                if wasUserCancellation {
                    self.lastSessionWasUserCancelled = true
                    print("🛑 NFC: User cancelled - extended cooldown will be applied")
                }
                
                DispatchQueue.main.async {
                    // Only report error if handlers still exist (meaning we didn't already call them in success path)
                    if wasUserCancellation {
                        print("🛑 NFC: Reporting cancellation to completion handlers")
                        self.readCompletion?(.failure(NFCError.sessionCancelled))
                        self.writeCompletion?(.failure(NFCError.sessionCancelled))
                    } else {
                        print("✅ NFC: Completion handlers already called (success path), ignoring Code 200")
                    }
                }
            case .readerSessionInvalidationErrorSessionTimeout:
                self.lastSessionWasUserCancelled = true  // Timeout also needs extended cooldown
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.sessionTimeout))
                    self.writeCompletion?(.failure(NFCError.sessionTimeout))
                }
            case .readerSessionInvalidationErrorFirstNDEFTagRead:
                // Session invalidated after first read (expected behavior, not an error)
                print("✅ NFC: Session auto-invalidated after first read (expected)")
                break
            case .readerSessionInvalidationErrorSystemIsBusy:
                // Code 202 - System is busy, need extended cooldown
                print("⚠️ NFC: System is busy (code 202) - extended cooldown will be applied")
                self.lastSessionWasUserCancelled = true
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.sessionCancelled))
                    self.writeCompletion?(.failure(NFCError.sessionCancelled))
                }
            default:
                // For any other error (including 203 - resource unavailable), apply extended cooldown
                print("⚠️ NFC: Error code \(readerError.code.rawValue) - extended cooldown will be applied")
                self.lastSessionWasUserCancelled = true
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(error))
                    self.writeCompletion?(.failure(error))
                }
            }
        } else {
            print("Non-NFCReaderError: \(error.localizedDescription)")
        }
        
        // Clean up session state and record invalidation time
        self.session = nil
        self.operation = nil
        self.readCompletion = nil
        self.writeCompletion = nil
        self.isSessionActive = false
        self.isStartingSession = false  // Reset in case cleanup happens during session start
        self.lastSessionInvalidationTime = Date()
        print("🧹 NFC: Session cleanup complete, cooldown timer started")
        
        // Signal that NFC sheet is now dismissed (minimal delay for animation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("⏱️ NFC: Setting sessionFullyDismissed = true")
            self.sessionFullyDismissed = true
        }
    }
    
    private func handleReadOperation(messages: [NFCNDEFMessage], session: NFCNDEFReaderSession) {
        guard let message = messages.first,
              let payload = message.records.first else {
            session.invalidate(errorMessage: NFCError.invalidData.localizedDescription)
            readCompletion?(.failure(NFCError.invalidData))
            isScanning = false
            return
        }
        
        if let tagID = parseContainerRecord(from: payload) {
            session.alertMessage = "Container tag read successfully!"
            session.invalidate()
            readCompletion?(.success(tagID))
            isScanning = false
        } else {
            session.invalidate(errorMessage: NFCError.invalidData.localizedDescription)
            readCompletion?(.failure(NFCError.invalidData))
            isScanning = false
        }
    }
    
    private func performRead(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        print("📖 NFC: Starting read operation...")
        print("🔍 NFC: Querying tag NDEF status before read...")
        
        // Query NDEF status first to ensure tag is properly initialized
        tag.queryNDEFStatus { [weak self] status, capacity, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ NFC: Query failed - \(error.localizedDescription)")
                session.invalidate(errorMessage: "Failed to read tag: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.readFailed))
                    self.isScanning = false
                }
                return
            }
            
            print("📊 NFC: Tag status = \(status.rawValue), capacity = \(capacity) bytes")
            
            switch status {
            case .notSupported:
                print("❌ NFC: Tag does not support NDEF")
                session.invalidate(errorMessage: NFCError.tagNotNDEF.localizedDescription)
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.tagNotNDEF))
                    self.isScanning = false
                }
                
            case .readOnly, .readWrite:
                print("✅ NFC: Tag supports NDEF, proceeding with read...")
                self.executeRead(tag: tag, session: session)
                
            @unknown default:
                print("⚠️ NFC: Unknown tag status, attempting read anyway...")
                self.executeRead(tag: tag, session: session)
            }
        }
    }
    
    private func executeRead(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { [weak self] message, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ NFC: Read failed - \(error.localizedDescription)")
                
                // Check if this is a transient "Tag Not NDEF formatted" error that we can retry
                let errorDescription = error.localizedDescription.lowercased()
                let isNDEFFormatError = errorDescription.contains("ndef") || errorDescription.contains("formatted")
                
                if isNDEFFormatError && self.readRetryCount < self.maxReadRetries {
                    self.readRetryCount += 1
                    print("🔄 NFC: Retrying read (attempt \(self.readRetryCount + 1)/\(self.maxReadRetries + 1))...")
                    
                    // Small delay before retry
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.executeRead(tag: tag, session: session)
                    }
                    return
                }
                
                session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.readFailed))
                    self.isScanning = false
                }
                return
            }
            
            guard let message = message,
                  let payload = message.records.first else {
                print("❌ NFC: No NDEF message or payload found")
                session.invalidate(errorMessage: NFCError.invalidData.localizedDescription)
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.invalidData))
                    self.isScanning = false
                }
                return
            }
            
            print("📦 NFC: NDEF message received, parsing...")
            
            if let tagID = self.parseContainerRecord(from: payload) {
                self.readCompleteTime = Date()
                let totalTime = self.readCompleteTime!.timeIntervalSince(self.scanStartTime ?? Date())
                let readTime = self.readCompleteTime!.timeIntervalSince(self.tagDetectedTime ?? Date())
                print("✅ NFC: Successfully parsed tag ID: \(tagID)")
                print("⏱️ NFC TIMING: Total=\(String(format: "%.3f", totalTime))s, Read=\(String(format: "%.3f", readTime))s")
                print("⏱️ NFC TIMING: About to call session.invalidate()")
                
                // Invalidate immediately without alert message for faster dismissal
                let invalidateStart = Date()
                session.invalidate()
                print("⏱️ NFC TIMING: session.invalidate() returned after \(String(format: "%.3f", Date().timeIntervalSince(invalidateStart)))s")
                
                print("⏱️ NFC TIMING: About to dispatch completion to main queue")
                DispatchQueue.main.async {
                    let dispatchDelay = Date().timeIntervalSince(self.readCompleteTime ?? Date())
                    print("⏱️ NFC TIMING: Main queue dispatch took \(String(format: "%.3f", dispatchDelay))s")
                    print("⏱️ NFC TIMING: Calling readCompletion callback")
                    self.readCompletion?(.success(tagID))
                    self.readCompletion = nil  // Clear to prevent double-call in didInvalidateWithError
                    self.isScanning = false
                    print("⏱️ NFC TIMING: Completion callback finished")
                }
            } else {
                print("❌ NFC: Failed to parse container record")
                session.invalidate(errorMessage: NFCError.invalidData.localizedDescription)
                DispatchQueue.main.async {
                    self.readCompletion?(.failure(NFCError.invalidData))
                    self.isScanning = false
                }
            }
        }
    }
    
    private func performWrite(tag: NFCNDEFTag, record: ContainerRecord, session: NFCNDEFReaderSession) {
        print("🔍 NFC: Querying tag NDEF status...")
        
        tag.queryNDEFStatus { status, capacity, error in
            if let error = error {
                print("❌ NFC: Query failed - \(error.localizedDescription)")
                session.invalidate(errorMessage: "Query failed: \(error.localizedDescription)")
                self.writeCompletion?(.failure(NFCError.writeFailed))
                self.isScanning = false
                return
            }
            
            print("📊 NFC: Tag status = \(status.rawValue), capacity = \(capacity) bytes")
            
            switch status {
            case .notSupported:
                print("❌ NFC: Tag does not support NDEF")
                session.invalidate(errorMessage: NFCError.tagNotNDEF.localizedDescription)
                self.writeCompletion?(.failure(NFCError.tagNotNDEF))
                self.isScanning = false
                
            case .readOnly:
                print("❌ NFC: Tag is read-only")
                session.invalidate(errorMessage: "Tag is read-only and cannot be written to.")
                self.writeCompletion?(.failure(NFCError.writeFailed))
                self.isScanning = false
                
            case .readWrite:
                print("✅ NFC: Tag is writable")
                
                guard let payload = self.createNDEFPayload(from: record) else {
                    print("❌ NFC: Failed to create NDEF payload")
                    session.invalidate(errorMessage: "Failed to create tag data.")
                    self.writeCompletion?(.failure(NFCError.writeFailed))
                    self.isScanning = false
                    return
                }
                
                let message = NFCNDEFMessage(records: [payload])
                print("📝 NFC: Writing NDEF message to tag...")
                
                tag.writeNDEF(message) { error in
                    if let error = error {
                        print("❌ NFC: Write failed - \(error.localizedDescription)")
                        session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                        self.writeCompletion?(.failure(NFCError.writeFailed))
                        self.isScanning = false
                        return
                    }
                    
                    print("✅ NFC: Write successful!")
                    print("🔄 NFC: [WRITE] About to set alert message and invalidate session")
                    print("🔄 NFC: [WRITE] Session state before invalidate - isReady: \(session.isReady)")
                    
                    // DIAGNOSTIC: Test if setting alert message causes issues
                    session.alertMessage = "Container information written successfully!"
                    print("🔄 NFC: [WRITE] Alert message set successfully")
                    
                    // DIAGNOSTIC: Test if manual invalidation causes issues
                    session.invalidate()
                    print("🔄 NFC: [WRITE] Session.invalidate() called")
                    
                    self.writeCompletion?(.success(()))
                    self.writeCompletion = nil  // Clear to prevent double-call in didInvalidateWithError
                    self.isScanning = false
                }
                
            @unknown default:
                session.invalidate(errorMessage: NFCError.unsupportedTag.localizedDescription)
                self.writeCompletion?(.failure(NFCError.unsupportedTag))
                self.isScanning = false
            }
        }
    }
}
