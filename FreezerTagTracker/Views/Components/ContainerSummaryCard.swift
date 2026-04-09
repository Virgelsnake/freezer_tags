import SwiftUI

struct ContainerSummaryCard: View {
    let items: [ContainerSummaryItem]

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items, id: \.self) { item in
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 6) {
                        rowTitle(item.title)
                        rowValue(item.value)
                    }
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 16) {
                        rowTitle(item.title)
                        Spacer(minLength: 12)
                        rowValue(item.value)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("What will be saved")
        .accessibilityValue(items.map { "\($0.title), \($0.value)" }.joined(separator: ", "))
        .accessibilityHint("Review the saved details before writing to the tag.")
    }

    private func rowTitle(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.secondary)
    }

    private func rowValue(_ value: String) -> some View {
        Text(value)
            .font(.body)
            .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
            .foregroundStyle(Color.primary)
    }
}

#Preview {
    ContainerSummaryCard(items: [
        ContainerSummaryItem(title: "Food name", value: "Beef stew"),
        ContainerSummaryItem(title: "Food type", value: "Beef"),
        ContainerSummaryItem(title: "Date frozen", value: "Today"),
        ContainerSummaryItem(title: "Best quality by", value: "9 August 2026"),
        ContainerSummaryItem(title: "Notes", value: "Family dinner leftovers"),
    ])
    .padding()
}
