import CoreGraphics

enum EventType: String, Codable, Equatable {
    case keyDown, keyUp, mouseDown, mouseUp, mouseMoved
}

struct InputEvent: Codable, Equatable {
    var type: EventType
    var keyCode: Int?
    var position: CGPoint?
    var delayMs: Int
}
