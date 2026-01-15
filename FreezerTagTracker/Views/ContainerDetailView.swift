import SwiftUI

struct ContainerDetailView: View {
    let initialContainer: ContainerRecord
    @ObservedObject var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearConfirmation = false
    @State private var isClearing = false
    @State private var showingEditView = false
    
    private var container: ContainerRecord {
        viewModel.containers.first { $0.id == initialContainer.id } ?? initialContainer
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
                        Text(container.formattedDateFrozen)
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(container.daysFrozenDescription)
                            .font(.subheadline)
                    }
                    
                    if let formattedDate = container.formattedBestBeforeDate {
                        Divider()
                        
                        HStack {
                            Image(systemName: bestBeforeIcon)
                                .foregroundStyle(bestBeforeColor)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Best Before")
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
                    Text("Notes")
                }
            }
            
            Section {
                HStack {
                    Image(systemName: "tag")
                        .foregroundStyle(.secondary)
                    Text("Tag ID")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(container.tagID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Technical Details")
            }
        }
        .navigationTitle("Container Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: {
                        print("🟠 ContainerDetailView: Edit button tapped")
                        showingEditView = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { 
                        print("🟠 ContainerDetailView: Clear & Reuse button tapped")
                        showingClearConfirmation = true 
                    }) {
                        Label("Clear & Reuse", systemImage: "trash")
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
        .confirmationDialog("Clear Container", isPresented: $showingClearConfirmation) {
            Button("Clear & Reuse", role: .destructive) {
                clearContainer()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will mark the container as empty and ready for reuse. The tag can be rewritten with new information.")
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
                Text("\(days)d left")
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
                Text("\(abs(days))d ago")
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
}
