import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    let macroStore = MacroStore()
    let locker = KeyboardLocker()
    let recorder = InputRecorder()
    let simulator = InputSimulator()
    lazy var scriptEngine = ScriptEngine(simulator: simulator)

    @Published var scriptOutput: String = ""
    @Published var isMainWindowOpen = false

    func runScript(_ source: String) {
        do {
            scriptOutput = try scriptEngine.run(source)
        } catch {
            scriptOutput = "Error: \(error.localizedDescription)"
        }
    }

    func startRecording() {
        recorder.startRecording()
    }

    func stopRecordingAndSave(name: String) {
        let events = recorder.stopRecording()
        let macro = Macro(id: UUID(), name: name, events: events, hotkey: nil)
        macroStore.save(macro: macro)
    }

    func playback(macro: Macro) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.simulator.playback(macro: macro)
        }
    }
}
