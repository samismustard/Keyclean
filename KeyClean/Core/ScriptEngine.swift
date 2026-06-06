import Foundation
import JavaScriptCore
import CoreGraphics

enum ScriptError: LocalizedError {
    case runtimeError(String)
    var errorDescription: String? {
        if case .runtimeError(let msg) = self { return msg }
        return nil
    }
}

final class ScriptEngine {
    private let simulator: InputSimulating
    private var logLines: [String] = []

    init(simulator: InputSimulating) {
        self.simulator = simulator
    }

    func run(_ source: String) throws -> String {
        logLines = []
        let context = JSContext()!
        var thrownError: String?

        context.exceptionHandler = { [weak self] _, exception in
            thrownError = exception?.toString() ?? "Unknown error"
        }

        setupAPIs(in: context)
        context.evaluateScript(source)

        if let err = thrownError {
            throw ScriptError.runtimeError(err)
        }

        return logLines.joined(separator: "\n")
    }

    private func setupAPIs(in context: JSContext) {
        let sim = simulator

        let keyboardType: @convention(block) (String) -> Void = { text in
            sim.typeString(text)
        }
        let keyboardPress: @convention(block) (String) -> Void = { combo in
            if let keyCombo = KeyCombo.parse(combo) {
                sim.pressKeyCombo(keyCombo)
            }
        }
        let keyboard = JSValue(newObjectIn: context)!
        keyboard.setObject(keyboardType, forKeyedSubscript: "type" as NSString)
        keyboard.setObject(keyboardPress, forKeyedSubscript: "press" as NSString)
        context.setObject(keyboard, forKeyedSubscript: "keyboard" as NSString)

        let mouseClick: @convention(block) (CGFloat, CGFloat) -> Void = { x, y in
            sim.click(at: CGPoint(x: x, y: y))
        }
        let mouseMove: @convention(block) (CGFloat, CGFloat) -> Void = { x, y in
            sim.moveCursor(to: CGPoint(x: x, y: y))
        }
        let mouse = JSValue(newObjectIn: context)!
        mouse.setObject(mouseClick, forKeyedSubscript: "click" as NSString)
        mouse.setObject(mouseMove, forKeyedSubscript: "moveTo" as NSString)
        context.setObject(mouse, forKeyedSubscript: "mouse" as NSString)

        let sleepFn: @convention(block) (Double) -> Void = { ms in
            if ms > 0 { Thread.sleep(forTimeInterval: ms / 1000.0) }
        }
        context.setObject(sleepFn, forKeyedSubscript: "sleep" as NSString)

        let consoleLog: @convention(block) (String) -> Void = { [weak self] msg in
            self?.logLines.append(msg)
        }
        let console = JSValue(newObjectIn: context)!
        console.setObject(consoleLog, forKeyedSubscript: "log" as NSString)
        context.setObject(console, forKeyedSubscript: "console" as NSString)
    }
}
