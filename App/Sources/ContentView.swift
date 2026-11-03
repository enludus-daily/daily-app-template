import SwiftUI

// ひな形の画面。その日のアプリで置き換える。
struct ContentView: View {
    // UserDefaults を使う（PrivacyInfo.xcprivacy に CA92.1 で申告済み）
    @AppStorage("tally.count") private var count = 0

    var body: some View {
        VStack(spacing: 24) {
            Text("\(count)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
                .accessibilityLabel("回数 \(count)")
            HStack(spacing: 16) {
                Button("リセット", role: .destructive) { apply { $0.reset() } }
                    .buttonStyle(.bordered)
                Button("1 たす") { apply { $0.increment() } }
                    .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
        }
        .padding()
    }

    private func apply(_ change: (inout Tally) -> Void) {
        var tally = Tally(count: count)
        change(&tally)
        withAnimation { count = tally.count }
    }
}

#Preview {
    ContentView()
}
