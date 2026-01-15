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
        switch self {
        case .tagNotFound:
            return "No NFC tag detected. Please hold your iPhone near the tag and try again."
        case .readFailed:
            return "Failed to read the NFC tag. Please try again."
        case .writeFailed:
            return "Failed to write to the NFC tag. Please try again."
        case .tagRemoved:
            return "Tag was removed too quickly. Please hold your iPhone steady near the tag."
        case .multipleTagsDetected:
            return "Multiple tags detected. Please remove extra tags and try again."
        case .unsupportedTag:
            return "This tag type is not supported. Please use an NDEF-formatted tag."
        case .sessionTimeout:
            return "NFC session timed out. Please try again."
        case .sessionCancelled:
            return "NFC scanning was cancelled."
        case .invalidData:
            return "Invalid data on tag. The tag may be corrupted or empty."
        case .tagNotNDEF:
            return "Tag is not NDEF formatted. Please use an NDEF-compatible tag."
        }
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
