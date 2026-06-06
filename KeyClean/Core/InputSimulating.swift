import CoreGraphics

protocol InputSimulating {
    func typeString(_ string: String)
    func pressKeyCombo(_ combo: KeyCombo)
    func click(at point: CGPoint)
    func moveCursor(to point: CGPoint)
    func playback(macro: Macro)
}
