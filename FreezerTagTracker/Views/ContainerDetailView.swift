import SwiftUI

struct ContainerDetailView: View {
    let container: ContainerRecord
    @ObservedObject var viewModel: ContainerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearConfirmation = false
    @State private var isClearing = false
    
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
                    NavigationLink(destination: EditContainerView(container: container, viewModel: viewModel)) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingClearConfirmation = true }) {
                        Label("Clear & Reuse", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
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
        
        viewModel.clearContainer(tagID: container.tagID) { result in
            isClearing = false
            
            switch result {
            case .success:
                dismiss()
            case .failure:
                dismiss()
            }
        }
    }
}

#Preview {
    NavigationView {
        ContainerDetailView(
            container: ContainerRecord(
                tagID: "test-tag-123",
                foodName: "Chicken Soup",
                dateFrozen: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                notes: "Contains vegetables and noodles"
            ),
            viewModel: ContainerViewModel(dataStore: DataStore(inMemory: true))
        )
    }
}
