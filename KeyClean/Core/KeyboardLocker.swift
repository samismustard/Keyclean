import CoreGraphics
import Foundation
import Combine

final class KeyboardLocker: ObservableObject {
    @Published private(set) var isLocked = false
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private static let mask: CGEventMask =
        (1 << CGEventType.keyDown.rawValue) |
        (1 << CGEventType.keyUp.rawValue) |
        (1 << CGEventType.flagsChanged.rawValue) |
        (1 << CGEventType.leftMouseDown.rawValue) |
        (1 << CGEventType.leftMouseUp.rawValue) |
        (1 << CGEventType.rightMouseDown.rawValue) |
        (1 << CGEventType.rightMouseUp.rawValue)

    private static let swallowCallback: CGEventTapCallBack = { _, _, _, _ in
        return nil
    }

    func lock() {
        guard !isLocked else { return }

        eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: KeyboardLocker.mask,
            callback: KeyboardLocker.swallowCallback,
            userInfo: nil
        )

        guard let tap = eventTap else { return }
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        isLocked = true
    }

    func unlock() {
        guard isLocked, let tap = eventTap else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        if let src = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        isLocked = false
    }

    func toggle() {
        isLocked ? unlock() : lock()
    }
}
