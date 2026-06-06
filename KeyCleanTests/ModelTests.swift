import XCTest
@testable import KeyClean

final class ModelTests: XCTestCase {
    func test_keyCombo_codableRoundTrip() throws {
        let combo = KeyCombo(keyCode: 37, modifierFlags: 1048576) // cmd+L
        let data = try JSONEncoder().encode(combo)
        let decoded = try JSONDecoder().decode(KeyCombo.self, from: data)
        XCTAssertEqual(combo, decoded)
    }

    func test_inputEvent_codableRoundTrip() throws {
        let event = InputEvent(type: .keyDown, keyCode: 37, position: nil, delayMs: 100)
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(InputEvent.self, from: data)
        XCTAssertEqual(event, decoded)
    }

    func test_macro_codableRoundTrip() throws {
        let macro = Macro(
            id: UUID(),
            name: "Test",
            events: [InputEvent(type: .keyDown, keyCode: 37, position: nil, delayMs: 0)],
            hotkey: nil
        )
        let data = try JSONEncoder().encode(macro)
        let decoded = try JSONDecoder().decode(Macro.self, from: data)
        XCTAssertEqual(macro.id, decoded.id)
        XCTAssertEqual(macro.name, decoded.name)
        XCTAssertEqual(macro.events.count, decoded.events.count)
    }

    func test_script_codableRoundTrip() throws {
        let script = Script(id: UUID(), name: "My Script", source: "keyboard.type('hi')", hotkey: nil)
        let data = try JSONEncoder().encode(script)
        let decoded = try JSONDecoder().decode(Script.self, from: data)
        XCTAssertEqual(script.id, decoded.id)
        XCTAssertEqual(script.source, decoded.source)
    }
}
