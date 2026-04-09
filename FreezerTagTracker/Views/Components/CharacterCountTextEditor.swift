import SwiftUI

struct CharacterCountTextEditor: View {
    @Binding var text: String

    let title: String
    let placeholder: String
    let characterLimit: Int

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)

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

                TextEditor(text: $text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(minHeight: 132)
                    .focused($isFocused)
                    .onChange(of: text) { newValue in
                        guard newValue.count > characterLimit else {
                            return
                        }

                        text = String(newValue.prefix(characterLimit))
                    }
            }

            Text("\(text.count) of \(characterLimit) characters")
                .font(.caption)
                .foregroundStyle(text.count >= characterLimit ? Color.red : Color.secondary)
                .accessibilityLabel("\(text.count) of \(characterLimit) characters")
        }
        .accessibilityElement(children: .contain)
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
