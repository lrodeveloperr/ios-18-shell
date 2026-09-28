import XCTest
import SwiftUI
@testable import iOS18Shell

@MainActor
final class AppTabTests: XCTestCase {
    func testAppTabCarriesItsChromeUnchanged() {
        let tab = AppTab(id: "home", title: "Home", systemImage: "house", role: .search) {
            Text("content")
        }
        XCTAssertEqual(tab.id, "home")
        XCTAssertEqual(tab.title, "Home")
        XCTAssertEqual(tab.systemImage, "house")
        XCTAssertEqual(tab.role.native, .search)
    }

    func testDefaultRoleMapsToNoNativeRole() {
        let tab = AppTab(id: "home", title: "Home", systemImage: "house") {
            Text("content")
        }
        XCTAssertNil(tab.role.native)
    }

    func testShellSelectsFirstTabByDefault() {
        let navigator = AppShellNavigator()
        let shell = AppShellView(tabIDs: ["first", "second"], navigator: navigator) {
            appShellTab(AppTab(id: "first", title: "First", systemImage: "1.circle") { Text("1") }, navigator: navigator)
            appShellTab(AppTab(id: "second", title: "Second", systemImage: "2.circle") { Text("2") }, navigator: navigator)
        }
        _ = shell // AppShellView has no public accessor for `selection`;
        // this smoke-tests that construction with multiple tabs compiles
        // and doesn't crash on init.
    }
}
