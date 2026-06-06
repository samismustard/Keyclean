import XCTest
import CoreGraphics
@testable import KeyClean

final class ScriptEngineTests: XCTestCase {
    var mock: MockInputSimulator!
    var engine: ScriptEngine!

    override func setUp() {
        super.setUp()
        mock = MockInputSimulator()
        engine = ScriptEngine(simulator: mock)
    }

    func test_keyboardType_callsSimulator() throws {
        let output = try engine.run("keyboard.type('hello')")
        XCTAssertEqual(mock.typedStrings, ["hello"])
        XCTAssertTrue(output.isEmpty)
    }

    func test_mouseClick_callsSimulator() throws {
        _ = try engine.run("mouse.click(100, 200)")
        XCTAssertEqual(mock.clicks.count, 1)
        XCTAssertEqual(mock.clicks[0].x, 100)
        XCTAssertEqual(mock.clicks[0].y, 200)
    }

    func test_mouseMoveT_callsSimulator() throws {
        _ = try engine.run("mouse.moveTo(50, 75)")
        XCTAssertEqual(mock.cursorMoves.count, 1)
        XCTAssertEqual(mock.cursorMoves[0].x, 50)
    }

    func test_consoleLog_appearsInOutput() throws {
        let output = try engine.run("console.log('hi there')")
        XCTAssertTrue(output.contains("hi there"))
    }

    func test_runtimeError_throwsWithMessage() {
        XCTAssertThrowsError(try engine.run("notAFunction()")) { error in
            let msg = error.localizedDescription
            XCTAssertFalse(msg.isEmpty)
        }
    }

    func test_sleep_doesNotThrow() throws {
        XCTAssertNoThrow(try engine.run("sleep(0)"))
    }
}
