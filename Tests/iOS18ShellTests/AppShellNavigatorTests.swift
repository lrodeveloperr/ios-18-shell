import XCTest
@testable import iOS18Shell

@MainActor
final class AppShellNavigatorTests: XCTestCase {
    func testPathDefaultsToEmptyThenPersistsWrites() {
        let navigator = AppShellNavigator()
        let binding = navigator.path(for: "home")
        XCTAssertTrue(binding.wrappedValue.isEmpty)

        binding.wrappedValue.append("detail-1")
        XCTAssertEqual(navigator.path(for: "home").wrappedValue.count, 1)
        // A different tab's path is unaffected.
        XCTAssertTrue(navigator.path(for: "search").wrappedValue.isEmpty)
    }

    func testSearchTextDefaultsToEmptyThenPersistsWrites() {
        let navigator = AppShellNavigator()
        XCTAssertEqual(navigator.searchText(for: "search").wrappedValue, "")

        navigator.searchText(for: "search").wrappedValue = "albums"
        XCTAssertEqual(navigator.searchText(for: "search").wrappedValue, "albums")
    }

    func testNavigateSelectsTabAndPushesRoute() {
        let navigator = AppShellNavigator()
        navigator.navigate(to: "library", pushing: 42)

        XCTAssertEqual(navigator.selection, "library")
        XCTAssertEqual(navigator.path(for: "library").wrappedValue.count, 1)
    }

    func testNavigateWithoutRouteOnlySelectsTab() {
        let navigator = AppShellNavigator()
        navigator.navigate(to: "home")

        XCTAssertEqual(navigator.selection, "home")
        XCTAssertTrue(navigator.path(for: "home").wrappedValue.isEmpty)
    }

    func testNavigateWithAbsentOptionalRouteOnlySelectsTab() {
        let navigator = AppShellNavigator()
        navigator.navigate(to: "home", pushing: Optional<Int>.none)

        XCTAssertEqual(navigator.selection, "home")
        XCTAssertTrue(navigator.path(for: "home").wrappedValue.isEmpty)
    }

    func testPopToRootClearsThatTabsPath() {
        let navigator = AppShellNavigator()
        navigator.path(for: "home").wrappedValue.append("detail-1")
        XCTAssertEqual(navigator.path(for: "home").wrappedValue.count, 1)

        navigator.popToRoot("home")
        XCTAssertTrue(navigator.path(for: "home").wrappedValue.isEmpty)
    }
}
