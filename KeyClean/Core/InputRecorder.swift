import CoreGraphics
import Foundation
import Combine

final class InputRecorder: ObservableObject {
    @Published private(set) var isRecording = false
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var recordedEvents: [InputEvent] = []
    private var lastEventTime: CFAbsoluteTime = 0

    private static let mask: CGEventMask =
        (1 << CGEventType.keyDown.rawValue) |
        (1 << CGEventType.keyUp.rawValue) |
        (1 << CGEventType.leftMouseDown.rawValue) |
        (1 << CGEventType.leftMouseUp.rawValue) |
        (1 << CGEventType.mouseMoved.rawValue)

    func startRecording() {
        recordedEvents = []
        lastEventTime = CFAbsoluteTimeGetCurrent()

        let selfPtr = Unmanaged.passRetained(self).toOpaque()

        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .tailAppendEventTap,
            options: .listenOnly,
            eventsOfInterest: InputRecorder.mask,
            callback: { _, type, event, userInfo -> Unmanaged<CGEvent>? in
                guard let userInfo else { return Unmanaged.passRetained(event) }
                let recorder = Unmanaged<InputRecorder>.fromOpaque(userInfo).takeUnretainedValue()
                recorder.record(type: type, event: event)
                return Unmanaged.passRetained(event)
            },
            userInfo: selfPtr
        )

        guard let tap = eventTap else { return }
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isRecording = true
    }

    func stopRecording() -> [InputEvent] {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let src = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes)
            }
        }
        eventTap = nil
        runLoopSource = nil
        isRecording = false
        return recordedEvents
    }

    private func record(type: CGEventType, event: CGEvent) {
        let now = CFAbsoluteTimeGetCurrent()
        let delayMs = Int((now - lastEventTime) * 1000)
        lastEventTime = now

        switch type {
        case .keyDown, .keyUp:
            let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
            recordedEvents.append(InputEvent(
                type: type == .keyDown ? .keyDown : .keyUp,
                keyCode: keyCode,
                position: nil,
                delayMs: delayMs
            ))
        case .leftMouseDown, .leftMouseUp:
            recordedEvents.append(InputEvent(
                type: type == .leftMouseDown ? .mouseDown : .mouseUp,
                keyCode: nil,
                position: event.location,
                delayMs: delayMs
            ))
        case .mouseMoved:
            recordedEvents.append(InputEvent(type: .mouseMoved, keyCode: nil, position: event.location, delayMs: delayMs))
        default:
            break
        }
    }
}
