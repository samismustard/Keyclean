import CoreGraphics

struct KeyCombo: Codable, Equatable {
    let keyCode: Int
    let modifierFlags: UInt64 // CGEventFlags.rawValue

    var cgEventFlags: CGEventFlags { CGEventFlags(rawValue: modifierFlags) }
}
