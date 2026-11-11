import UIKit
import XCTest

// 主な流れを自動でタップし、1 操作ごとに全部の画面を撮る（CI の artifact `flow-screenshots`）。
// あわせて、主なボタン（accessibilityIdentifier が "main." で始まるもの）が画面の中に収まり、押せることを確かめる。
// その日のアプリでは MainFlow だけを書き換える（手順書「9.5 見直しのループ」）。

/// その日のアプリの主な流れ。
enum MainFlow {
    /// 起動引数（見本のデータで開くなど。保存されたデータを壊さないもの）
    static let launchArguments: [String] = []

    /// 1 操作ずつ。各操作のあとに撮る。
    static let steps: [Step] = [
        .tap("main.increment"),
        .tap("main.increment"),
        .tap("main.reset"),
    ]
}

enum Step {
    /// accessibilityIdentifier で探してタップする（押す前に、画面の中にあり押せることを確かめる）
    case tap(String)
    /// 画面の上に向かってスワイプする（ページ送り・下の中身を出す）
    case swipeUp
    /// 待つ（秒）。動きの途中を撮るときに使う
    case wait(Double)

    var label: String {
        switch self {
        case .tap(let id): "tap-" + id.replacingOccurrences(of: ".", with: "_")
        case .swipeUp: "swipe-up"
        case .wait(let s): "wait-\(Int(s * 1000))ms"
        }
    }
}

@MainActor
final class MainFlowUITests: XCTestCase {
    /// 起動直後と各操作のあとに、いま見えている "main." の部品がすべて画面の中にあり押せること
    func testMainButtonsAreOnScreenAndHittable() throws {
        continueAfterFailure = true
        let app = launch()
        let found = assertMainElementsOnScreen(app, when: "起動直後")
        XCTAssertGreaterThan(found, 0, "主なボタンに accessibilityIdentifier(\"main.…\") を付けてください")
        for (i, step) in MainFlow.steps.enumerated() {
            perform(step, in: app)
            assertMainElementsOnScreen(app, when: "\(i + 1) 番目の操作（\(step.label)）のあと")
        }
    }

    /// 主な流れをたどり、1 操作ごとに撮る
    func testWalkthroughScreenshots() throws {
        continueAfterFailure = false
        let app = launch()
        shoot("00-launch")
        for (i, step) in MainFlow.steps.enumerated() {
            perform(step, in: app)
            shoot(String(format: "%02d-%@", i + 1, step.label))
        }
    }

    // MARK: -

    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += MainFlow.launchArguments
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        return app
    }

    private func perform(_ step: Step, in app: XCUIApplication) {
        switch step {
        case .tap(let id):
            let element = app.descendants(matching: .any).matching(identifier: id).firstMatch
            XCTAssertTrue(element.waitForExistence(timeout: 10), "\(id) が見つかりません")
            assertOnScreen(element, in: app, name: id)
            element.tap()
        case .swipeUp:
            app.windows.firstMatch.swipeUp()
        case .wait(let seconds):
            _ = XCTWaiter.wait(for: [XCTestExpectation(description: "wait")], timeout: seconds)
        }
        // 動きが落ち着くのを少し待つ
        _ = XCTWaiter.wait(for: [XCTestExpectation(description: "settle")], timeout: 1.0)
    }

    @discardableResult
    private func assertMainElementsOnScreen(_ app: XCUIApplication, when: String) -> Int {
        let query = app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'main.'"))
        let elements = query.allElementsBoundByIndex
        for element in elements {
            XCTContext.runActivity(named: "\(when)：\(element.identifier)") { _ in
                assertOnScreen(element, in: app, name: element.identifier)
            }
        }
        return elements.count
    }

    /// 画面（ウィンドウ）の中に全部が収まり、押せること。下で切れている・ほかの部品の下にあると失敗する
    private func assertOnScreen(_ element: XCUIElement, in app: XCUIApplication, name: String) {
        let window = app.windows.firstMatch.frame
        let frame = element.frame
        XCTAssertFalse(frame.isEmpty, "\(name) の大きさが 0 です")
        XCTAssertTrue(window.insetBy(dx: -0.5, dy: -0.5).contains(frame),
                      "\(name) が画面からはみ出しています（部品 \(frame)、画面 \(window)）。スクロールしないと押せない位置に主なボタンを置かない")
        XCTAssertTrue(element.isHittable, "\(name) が押せません（隠れている・画面の外）")
    }

    /// 全部の画面（iPhone Duo では外側と内側）を撮って、結果に残す。
    /// まっ黒な画面は残さない（Duo の内側は CI のシミュレータでは閉じた状態のため描かれない。2026-11-11 確認）
    private func shoot(_ name: String) {
        let device = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? "device"
        for (i, screen) in XCUIScreen.screens.enumerated() {
            let screenshot = screen.screenshot()
            if isAllBlack(screenshot.image) { continue }
            let shot = XCTAttachment(screenshot: screenshot)
            shot.name = "\(device)-\(name)-screen\(i)"
            shot.lifetime = .keepAlways
            add(shot)
        }
    }

    /// 32×32 に縮めて、RGB がすべて 0 なら true
    private func isAllBlack(_ image: UIImage) -> Bool {
        guard let cg = image.cgImage else { return false }
        let side = 32
        var pixels = [UInt8](repeating: 0, count: side * side * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let ctx = CGContext(data: buffer.baseAddress, width: side, height: side, bitsPerComponent: 8,
                                      bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { return false }
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: side, height: side))
            return true
        }
        guard drawn else { return false }
        return stride(from: 0, to: pixels.count, by: 4).allSatisfy { pixels[$0] == 0 && pixels[$0 + 1] == 0 && pixels[$0 + 2] == 0 }
    }
}
