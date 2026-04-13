import SwiftUI

struct CharacterCountTextEditor: View {
    @Binding var text: String

    let title: String?
    let accessibilityLabel: String
    let placeholder: String
    let characterLimit: Int

    @FocusState private var isFocused: Bool
    private let externalFocus: FocusState<Bool>.Binding?

    init(
        text: Binding<String>,
        title: String?,
        accessibilityLabel: String? = nil,
        placeholder: String,
        characterLimit: Int,
        focus: FocusState<Bool>.Binding? = nil
    ) {
        _text = text
        self.title = title
        self.accessibilityLabel = accessibilityLabel ?? title ?? "Text editor"
        self.placeholder = placeholder
        self.characterLimit = characterLimit
        self.externalFocus = focus
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.headline)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(.separator), lineWidth: 1)
                    )

                if text.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                        .allowsHitTesting(false)
                }

                if let externalFocus {
                    editor
                        .focused(externalFocus)
                } else {
                    editor
                        .focused($isFocused)
                }
            }

            Text("\(text.count) of \(characterLimit) characters")
                .font(.caption)
                .foregroundStyle(text.count >= characterLimit ? Color.red : Color.secondary)
                .accessibilityLabel("\(text.count) of \(characterLimit) characters")
        }
        .accessibilityElement(children: .contain)
    }

    private var editor: some View {
        TextEditor(text: $text)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(minHeight: 132)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(text.isEmpty ? "Empty" : text)
            .accessibilityHint("Optional. Up to \(characterLimit) characters.")
            .accessibilityIdentifier("addContainer.notesEditor")
            .onChange(of: text) { newValue in
                guard newValue.count > characterLimit else {
                    return
                }

                text = String(newValue.prefix(characterLimit))
            }
    }
}

#Preview {
    CharacterCountTextEditor(
        text: .constant("Family dinner leftovers"),
        title: "Notes",
        placeholder: "Optional notes",
        characterLimit: 200
    )
    .padding()
}
