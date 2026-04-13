import SwiftUI

struct ContainerDetailView: View {
    let initialContainer: ContainerRecord
    @ObservedObject var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearConfirmation = false
    @State private var isClearing = false
    @State private var showingEditView = false
    @State private var hasSpokenSummary = false

    private let settingsStore: AddContainerSettingsProviding
    private let spokenFeedbackService: SpokenFeedbackServing
    private let accessibilityAnnouncementService: AccessibilityAnnouncementServing
    private let accessibilityStatusProvider: AccessibilityStatusProviding

    init(
        initialContainer: ContainerRecord,
        viewModel: ContainerViewModel,
        settingsStore: AddContainerSettingsProviding = AddContainerSettingsStore(),
        spokenFeedbackService: SpokenFeedbackServing = SpokenFeedbackService(),
        accessibilityAnnouncementService: AccessibilityAnnouncementServing = AccessibilityAnnouncementService(),
        accessibilityStatusProvider: AccessibilityStatusProviding = SystemAccessibilityStatusProvider()
    ) {
        self.initialContainer = initialContainer
        self.viewModel = viewModel
        self.settingsStore = settingsStore
        self.spokenFeedbackService = spokenFeedbackService
        self.accessibilityAnnouncementService = accessibilityAnnouncementService
        self.accessibilityStatusProvider = accessibilityStatusProvider
    }
    
    private var container: ContainerRecord {
        viewModel.containers.first { $0.id == initialContainer.id } ?? initialContainer
    }

    private var strings: AppStrings {
        settingsStore.load().language.strings
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                        
                        Text(container.foodName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        Text(container.formattedDateFrozen(in: settingsStore.load().language))
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(container.daysFrozenDescription(in: settingsStore.load().language))
                            .font(.subheadline)
                    }
                    
                    if let formattedDate = container.formattedBestBeforeDate(in: settingsStore.load().language) {
                        Divider()
                        
                        HStack {
                            Image(systemName: bestBeforeIcon)
                                .foregroundStyle(bestBeforeColor)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(strings.bestBefore)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(formattedDate)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(bestBeforeColor)
                            }
                            
                            Spacer()
                            
                            if container.bestBeforeStatus != .fresh {
                                bestBeforeStatusBadge
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(bestBeforeBackgroundColor)
                        .cornerRadius(8)
                    }
                }
                .padding(.vertical, 8)
            }
            
            if let notes = container.notes, !notes.isEmpty {
                Section {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "note.text")
                            .foregroundStyle(.secondary)
                        Text(notes)
                            .font(.body)
                    }
                } header: {
                    Text(strings.notes)
                }
            }
            
            Section {
                HStack {
                    Image(systemName: "tag")
                        .foregroundStyle(.secondary)
                    Text(strings.tagID)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(container.tagID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(strings.technicalDetails)
            }
        }
        .navigationTitle(strings.containerDetails)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        print("🟠 ContainerDetailView: Edit button tapped")
                        showingEditView = true
                    }) {
                        Label(strings.edit, systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { 
                        print("🟠 ContainerDetailView: Clear & Reuse button tapped")
                        showingClearConfirmation = true 
                    }) {
                        Label(strings.clearAndReuse, systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .background(
            NavigationLink(
                destination: EditContainerView(container: initialContainer, viewModel: viewModel),
                isActive: $showingEditView
            ) {
                EmptyView()
            }
            .hidden()
        )
        .confirmationDialog(strings.clearContainerTitle, isPresented: $showingClearConfirmation) {
            Button(strings.clearAndReuse, role: .destructive) {
                clearContainer()
            }
            Button(strings.cancel, role: .cancel) { }
        } message: {
            Text(strings.clearContainerMessage)
        }
        .onAppear {
            speakSummaryIfNeeded()
        }
    }
    
    private func clearContainer() {
        isClearing = true
        
        viewModel.clearContainer(tagID: initialContainer.tagID) { result in
            isClearing = false
            
            switch result {
            case .success:
                dismiss()
            case .failure:
                dismiss()
            }
        }
    }
    
    private var bestBeforeColor: Color {
        switch container.bestBeforeStatus {
        case .none, .fresh:
            return .secondary
        case .approaching:
            return .orange
        case .expired:
            return .red
        }
    }
    
    private var bestBeforeBackgroundColor: Color {
        switch container.bestBeforeStatus {
        case .none, .fresh:
            return Color.clear
        case .approaching:
            return Color.orange.opacity(0.1)
        case .expired:
            return Color.red.opacity(0.1)
        }
    }
    
    private var bestBeforeIcon: String {
        switch container.bestBeforeStatus {
        case .none, .fresh:
            return "calendar.badge.checkmark"
        case .approaching:
            return "exclamationmark.triangle.fill"
        case .expired:
            return "xmark.circle.fill"
        }
    }
    
    @ViewBuilder
    private var bestBeforeStatusBadge: some View {
        switch container.bestBeforeStatus {
        case .approaching:
            if let days = container.daysUntilBestBefore {
                Text(strings.daysLeft(days))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
        case .expired:
            if let days = container.daysUntilBestBefore {
                Text(strings.daysAgoShort(abs(days)))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(12)
            }
        default:
            EmptyView()
        }
    }

    private func speakSummaryIfNeeded() {
        guard !hasSpokenSummary else {
            return
        }

        hasSpokenSummary = true

        let settings = settingsStore.load()
        guard settings.spokenGuidanceEnabled else {
            return
        }

        let message = container.spokenSummary(in: settings.language)
        if accessibilityStatusProvider.isVoiceOverRunning {
            accessibilityAnnouncementService.announce(message, language: settings.language)
        } else {
            spokenFeedbackService.speak(message, language: settings.language)
        }
    }
}

#Preview {
    NavigationView {
        ContainerDetailView(
            initialContainer: ContainerRecord(
                tagID: "test-tag-123",
                foodName: "Chicken Soup",
                dateFrozen: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                notes: "Contains vegetables and noodles"
            ),
            viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true))
        )
    }
    .environmentObject(SettingsViewModel())
}
