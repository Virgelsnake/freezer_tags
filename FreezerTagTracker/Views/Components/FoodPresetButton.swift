import SwiftUI

struct FoodPresetButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 16 : 14)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? Color.blue : Color(.secondarySystemBackground))
            )
            .overlay(borderStyle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Adds a suggested best-quality date based on USDA guidance.")
    }
    private var borderStyle: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(isSelected ? Color.blue : Color(.separator), lineWidth: isSelected ? 0 : 1)
    }
}

#Preview {
    VStack(spacing: 16) {
        FoodPresetButton(title: "Beef", isSelected: false, action: {})
        FoodPresetButton(title: "Prepared meal", isSelected: true, action: {})
    }
    .padding()
}
