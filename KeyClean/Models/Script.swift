import Foundation

struct Script: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var source: String
    var hotkey: KeyCombo?
}
