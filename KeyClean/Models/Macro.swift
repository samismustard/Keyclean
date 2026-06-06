import Foundation

struct Macro: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var events: [InputEvent]
    var hotkey: KeyCombo?
}
