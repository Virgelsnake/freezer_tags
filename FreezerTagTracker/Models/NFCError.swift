import Foundation

enum NFCError: Error, LocalizedError, Equatable {
    case tagNotFound
    case readFailed
    case writeFailed
    case tagRemoved
    case multipleTagsDetected
    case unsupportedTag
    case sessionTimeout
    case sessionCancelled
    case invalidData
    case tagNotNDEF
    
    var errorDescription: String? {
        AppLanguage.current.strings.nfcError(self)
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .tagNotFound, .sessionTimeout:
            return "Make sure NFC is enabled on your device and try holding your iPhone closer to the tag."
        case .readFailed, .writeFailed:
            return "Tap 'Retry' to try again."
        case .tagRemoved:
            return "Hold your iPhone steady near the tag for 2-3 seconds."
        case .multipleTagsDetected:
            return "Move extra tags away and scan again."
        case .unsupportedTag, .tagNotNDEF:
            return "Use NTAG213 or NTAG215 tags for best compatibility."
        case .sessionCancelled:
            return nil
        case .invalidData:
            return "Try writing new data to the tag or use a different tag."
        }
    }
}
