import XCTest
import CoreGraphics
@testable import KeyClean

final class InputSimulatorTests: XCTestCase {
    func test_mock_conformsToProtocol() {
        let sim: InputSimulating = MockInputSimulator()
        sim.typeString("hello")
        sim.click(at: CGPoint(x: 100, y: 200))
        sim.moveCursor(to: CGPoint(x: 50, y: 50))
        sim.pressKeyCombo(KeyCombo(keyCode: 37, modifierFlags: 1048576))
        let macro = Macro(id: UUID(), name: "t", events: [], hotkey: nil)
        sim.playback(macro: macro)
    }

    func test_inputSimulator_conformsToProtocol() {
        let sim: InputSimulating = InputSimulator()
        XCTAssertNotNil(sim)
    }
}
