import SwiftUI
import Combine

struct HomeView: View {
    @StateObject private var viewModel: ContainerViewModel
    @StateObject private var nfcManager = NFCManager.shared
    @State private var showScanSheet = false
    @State private var scannedContainer: ContainerRecord?
    @State private var showContainerDetail = false
    @State private var waitingForNFCDismissal = false
    @State private var showSettings = false
    private let settingsViewModelFactory: () -> SettingsViewModel

    init(
        viewModel: ContainerViewModel = ContainerViewModel(),
        settingsViewModelFactory: @escaping () -> SettingsViewModel = { SettingsViewModel() }
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.settingsViewModelFactory = settingsViewModelFactory
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "snowflake")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text("Freezer Tag Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Tap an NFC tag to manage your frozen containers")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    NavigationLink {
                        AddContainerView(viewModel: viewModel)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Add Container")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    .accessibilityIdentifier("home.addContainer")
                    
                    Button(action: {
                        print("⏱️ HomeView: Scan Container button tapped")
                        showScanSheet = true
                    }) {
                        HStack {
                            Image(systemName: "viewfinder.circle.fill")
                                .font(.title2)
                            Text("Scan Container")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                    }
                    
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier("home.settings")
                }
            }
            .sheet(isPresented: $showScanSheet) {
                ScanView(viewModel: viewModel) { container in
                    print("⏱️ HomeView TIMING: onScanSuccess callback received")
                    scannedContainer = container
                    waitingForNFCDismissal = true
                    print("⏱️ HomeView TIMING: Container stored, waiting for NFC sheet to dismiss")
                    showScanSheet = false
                }
            }
            .onChange(of: nfcManager.sessionFullyDismissed) { dismissed in
                if dismissed && waitingForNFCDismissal && scannedContainer != nil {
                    print("⏱️ HomeView TIMING: NFC session fully dismissed, now showing container detail")
                    waitingForNFCDismissal = false
                    showContainerDetail = true
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationView {
                    SettingsView(viewModel: settingsViewModelFactory())
                }
            }
        }
        .navigationViewStyle(.stack)
        .overlay {
            // Loading overlay while waiting for NFC sheet to dismiss
            // Positioned in upper half to avoid NFC sheet (~40% from top)
            if waitingForNFCDismissal {
                GeometryReader { geometry in
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Loading container...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(32)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .position(x: geometry.size.width / 2, y: geometry.size.height * 0.3)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: waitingForNFCDismissal)
        .fullScreenCover(isPresented: $showContainerDetail, onDismiss: {
            print("⏱️ HomeView TIMING: Container detail dismissed")
            scannedContainer = nil
        }) {
            if let container = scannedContainer {
                NavigationView {
                    ContainerDetailView(initialContainer: container, viewModel: viewModel)
                        .onAppear {
                            print("⏱️ HomeView TIMING: ContainerDetailView appeared")
                        }
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    showContainerDetail = false
                                }
                            }
                        }
                }
                .navigationViewStyle(.stack)
            }
        }
    }
}

#Preview {
    HomeView()
}
