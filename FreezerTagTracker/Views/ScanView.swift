import SwiftUI

enum ScanState {
    case scanning
    case success
    case error(String)
}

struct ScanView: View {
    @ObservedObject var viewModel: ContainerViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scanState: ScanState = .scanning
    @State private var hasScanned = false
    @State private var scanCompleted = false
    @State private var hasAnnouncedReadyToScan = false
    
    /// Callback when scan succeeds with a container
    var onScanSuccess: ((ContainerRecord) -> Void)?
    
    init(viewModel: ContainerViewModel, onScanSuccess: ((ContainerRecord) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onScanSuccess = onScanSuccess
    }
    
    var body: some View {
        let strings = settingsViewModel.strings

        NavigationView {
            ZStack {
                Color(.systemBackground)
                
                if case .error(let message) = scanState {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.orange)
                        
                        Text(strings.scanFailed)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: startScanning) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text(strings.tryAgain)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 20)
                    }
                }
            }
            .navigationTitle(strings.scanContainer)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("⏱️ ScanView TIMING: onAppear called - hasScanned=\(hasScanned), scanCompleted=\(scanCompleted)")
            if !hasScanned && !scanCompleted {
                announceReadyToScanIfNeeded()
                startScanning()
            } else {
                print("⚠️ ScanView: Skipping scan - already scanned or completed")
            }
        }
    }

    private func announceReadyToScanIfNeeded() {
        guard !hasAnnouncedReadyToScan else {
            return
        }

        hasAnnouncedReadyToScan = true
        viewModel.handleScanScreenAppeared()
    }
    
    private func startScanning() {
        scanState = .scanning
        hasScanned = true
        let scanStartTime = Date()
        print("⏱️ ScanView TIMING: startScanning called")
        
        viewModel.scanContainer { result in
            let callbackTime = Date()
            print("⏱️ ScanView TIMING: scanContainer callback received after \(String(format: "%.3f", callbackTime.timeIntervalSince(scanStartTime)))s")
            
            switch result {
            case .success(let container):
                scanState = .success
                scanCompleted = true  // Mark as completed to prevent re-scanning
                print("⏱️ ScanView TIMING: About to call dismiss()")
                // Dismiss immediately, then call success callback
                dismiss()
                print("⏱️ ScanView TIMING: dismiss() called, now calling onScanSuccess")
                onScanSuccess?(container)
                print("⏱️ ScanView TIMING: onScanSuccess callback completed")
            case .failure(let error):
                scanState = .error(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ScanView(viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true)))
        .environmentObject(SettingsViewModel())
}
