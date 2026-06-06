import CoreGraphics
@testable import KeyClean

final class MockInputSimulator: InputSimulating {
    var typedStrings: [String] = []
    var pressedCombos: [KeyCombo] = []
    var clicks: [CGPoint] = []
    var cursorMoves: [CGPoint] = []
    var playedMacros: [Macro] = []

    func typeString(_ string: String) { typedStrings.append(string) }
    func pressKeyCombo(_ combo: KeyCombo) { pressedCombos.append(combo) }
    func click(at point: CGPoint) { clicks.append(point) }
    func moveCursor(to point: CGPoint) { cursorMoves.append(point) }
    func playback(macro: Macro) { playedMacros.append(macro) }
}
