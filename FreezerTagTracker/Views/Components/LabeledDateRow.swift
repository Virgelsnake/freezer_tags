import SwiftUI

struct LabeledDateRow: View {
    let title: String
    let value: String
    let isEmpty: Bool
    let accessibilityHint: String
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        rowLabel
                        rowValue
                    }
                } else {
                    HStack(spacing: 16) {
                        rowLabel
                        Spacer(minLength: 12)
                        rowValue
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityHint(accessibilityHint)
    }

    private var rowLabel: some View {
        Text(title)
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.primary)
    }

    private var rowValue: some View {
        HStack(spacing: 10) {
            Text(value)
                .font(.body)
                .foregroundStyle(isEmpty ? Color.secondary : Color.primary)
                .multilineTextAlignment(.trailing)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        LabeledDateRow(title: "Date frozen", value: "Today", isEmpty: false, accessibilityHint: "Double tap to change the date.", action: {})
        LabeledDateRow(title: "Best quality by", value: "Not set", isEmpty: true, accessibilityHint: "Double tap to change the date.", action: {})
    }
    .padding()
}
