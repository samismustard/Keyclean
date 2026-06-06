import CoreGraphics
import Foundation

final class InputSimulator: InputSimulating {
    private let source = CGEventSource(stateID: .hidSystemState)

    func typeString(_ string: String) {
        for scalar in string.unicodeScalars {
            let uniChar = [UniChar(scalar.value)]
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
            keyDown?.keyboardSetUnicodeString(stringLength: 1, unicodeString: uniChar)
            keyUp?.keyboardSetUnicodeString(stringLength: 1, unicodeString: uniChar)
            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        }
    }

    func pressKeyCombo(_ combo: KeyCombo) {
        let vk = CGKeyCode(combo.keyCode)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: vk, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: vk, keyDown: false)
        keyDown?.flags = combo.cgEventFlags
        keyUp?.flags = combo.cgEventFlags
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    func click(at point: CGPoint) {
        let down = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown,
                           mouseCursorPosition: point, mouseButton: .left)
        let up = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp,
                         mouseCursorPosition: point, mouseButton: .left)
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }

    func moveCursor(to point: CGPoint) {
        let move = CGEvent(mouseEventSource: source, mouseType: .mouseMoved,
                           mouseCursorPosition: point, mouseButton: .left)
        move?.post(tap: .cghidEventTap)
    }

    func playback(macro: Macro) {
        for event in macro.events {
            if event.delayMs > 0 {
                Thread.sleep(forTimeInterval: Double(event.delayMs) / 1000.0)
            }
            switch event.type {
            case .keyDown, .keyUp:
                guard let keyCode = event.keyCode else { continue }
                let isDown = event.type == .keyDown
                let vk = CGKeyCode(keyCode)
                let cgEvent = CGEvent(keyboardEventSource: source, virtualKey: vk, keyDown: isDown)
                cgEvent?.post(tap: .cghidEventTap)
            case .mouseDown, .mouseUp:
                guard let pos = event.position else { continue }
                let mouseType: CGEventType = event.type == .mouseDown ? .leftMouseDown : .leftMouseUp
                let cgEvent = CGEvent(mouseEventSource: source, mouseType: mouseType,
                                      mouseCursorPosition: pos, mouseButton: .left)
                cgEvent?.post(tap: .cghidEventTap)
            case .mouseMoved:
                guard let pos = event.position else { continue }
                moveCursor(to: pos)
            }
        }
    }
}
