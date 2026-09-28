import XCTest
import UIKit

final class ShellExampleUITests: XCTestCase {
    func testCompactLibraryAndAccountAreReachable() throws {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            throw XCTSkip("Compact tab bar check runs on iPhone")
        }
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["shell.home.content"].waitForExistence(timeout: 15))
        let library = app.tabBars.buttons["Library"]
        XCTAssertTrue(library.exists)
        library.tap()

        XCTAssertTrue(app.buttons["Downloads"].waitForExistence(timeout: 5))
        app.buttons["Downloads"].tap()
        XCTAssertTrue(app.staticTexts["shell.downloads.content"].waitForExistence(timeout: 5))

        let account = app.tabBars.buttons["Account"]
        XCTAssertTrue(account.exists)
        account.tap()
        XCTAssertTrue(app.staticTexts["shell.account.content"].waitForExistence(timeout: 5))
    }

    func testRegularLayoutLaunchesAndNavigatesToSearch() throws {
        guard UIDevice.current.userInterfaceIdiom == .pad else {
            throw XCTSkip("Regular sidebar check runs on iPad")
        }
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["shell.home.content"].waitForExistence(timeout: 15))
        let search = app.tabBars.buttons["Search"]
        XCTAssertTrue(search.exists)
        search.tap()
        XCTAssertTrue(app.staticTexts["shell.search.content"].waitForExistence(timeout: 5))
    }
}
