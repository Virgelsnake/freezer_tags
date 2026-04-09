import SwiftUI

struct TagWriteResultView: View {
    let result: TagWriteResult
    let canReadDetailsAgain: Bool
    let onReadDetailsAgain: () -> Void
    let onDone: () -> Void
    let onTryAgain: () -> Void
    let onGoBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                statusHeader

                if case .failure(let message) = result {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                }

                actionSection
            }
            .padding(24)
        }
        .accessibilityIdentifier("addContainer.result.screen")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var statusHeader: some View {
        switch result {
        case .success(let record):
            VStack(alignment: .leading, spacing: 16) {
                statusBadge(title: "Saved", systemImage: "checkmark.circle.fill", color: .green)

                Text("Saved to your container")
                    .font(.largeTitle.weight(.bold))

                Text("\(record.foodName) has been saved and the tag was updated.")
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(record.foodName) saved to your container. The tag was updated.")
        case .failure:
            VStack(alignment: .leading, spacing: 16) {
                statusBadge(title: "Needs attention", systemImage: "xmark.circle.fill", color: .red)

                Text("That did not save to the tag")
                    .font(.largeTitle.weight(.bold))

                Text("Try holding your iPhone a little closer and keep it still.")
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("That did not save to the tag. Try holding your iPhone a little closer and keep it still.")
        }
    }

    private func statusBadge(title: String, systemImage: String, color: Color) -> some View {
        Label(title, systemImage: systemImage)
            .font(.headline.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(color.opacity(0.12))
            )
    }

    @ViewBuilder
    private var actionSection: some View {
        switch result {
        case .success:
            VStack(alignment: .leading, spacing: 14) {
                Button(action: onDone) {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(ResultPrimaryActionButtonStyle())
                .accessibilityIdentifier("addContainer.doneButton")

                if canReadDetailsAgain {
                    Button(action: onReadDetailsAgain) {
                        Text("Read details again")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .foregroundStyle(Color.blue)
                    .accessibilityHint("Replays the saved container details.")
                    .accessibilityIdentifier("addContainer.readDetailsAgainButton")
                }
            }
        case .failure:
            VStack(alignment: .leading, spacing: 14) {
                Button(action: onTryAgain) {
                    Text("Try again")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                }
                .buttonStyle(ResultPrimaryActionButtonStyle())
                .accessibilityIdentifier("addContainer.tryAgainButton")

                Button("Go back", action: onGoBack)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityHint("Returns to the review step without losing the details.")
                    .accessibilityIdentifier("addContainer.goBackButton")
            }
        }
    }
}

private struct ResultPrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.white)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.85) : Color.blue)
            )
            .opacity(configuration.isPressed ? 0.92 : 1)
    }
}

#Preview {
    TagWriteResultView(
        result: .success(record: ContainerRecord(tagID: "preview-tag", foodName: "Beef stew", dateFrozen: Date())),
        canReadDetailsAgain: true,
        onReadDetailsAgain: {},
        onDone: {},
        onTryAgain: {},
        onGoBack: {}
    )
}
