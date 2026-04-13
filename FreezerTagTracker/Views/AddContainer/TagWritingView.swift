import SwiftUI

struct TagWritingView: View {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.system(size: 64))
                .foregroundStyle(Color.blue)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text("Hold your phone near the tag")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)

                Text("Keep the top of your iPhone close to the container tag until you feel confirmation.")
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }

            if accessibilityReduceMotion {
                Label("Writing in progress", systemImage: "hourglass")
                    .font(.headline)
                    .foregroundStyle(Color.secondary)
                    .accessibilityHint("Animation is reduced. Keep holding your phone near the tag.")
            } else {
                ProgressView()
                    .controlSize(.large)
                    .accessibilityLabel("Writing in progress")
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("addContainer.writing.screen")
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TagWritingView()
}
