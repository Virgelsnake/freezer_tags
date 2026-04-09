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
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var statusHeader: some View {
        switch result {
        case .success(let record):
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.green)
                    .accessibilityHidden(true)

                Text("Saved to your container")
                    .font(.largeTitle.weight(.bold))

                Text("\(record.foodName) has been saved and the tag was updated.")
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
        case .failure:
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.red)
                    .accessibilityHidden(true)

                Text("That did not save to the tag")
                    .font(.largeTitle.weight(.bold))

                Text("Try holding your iPhone a little closer and keep it still.")
                    .font(.body)
                    .foregroundStyle(Color.secondary)
            }
        }
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

                if canReadDetailsAgain {
                    Button(action: onReadDetailsAgain) {
                        Text("Read details again")
                            .font(.body.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .foregroundStyle(Color.blue)
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

                Button("Go back", action: onGoBack)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
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
