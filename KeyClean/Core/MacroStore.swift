import Foundation
import Combine

final class MacroStore: ObservableObject {
    @Published private(set) var macros: [Macro] = []
    @Published private(set) var scripts: [Script] = []

    private let macrosURL: URL
    private let scriptsURL: URL

    init(directory: URL = .applicationSupportDirectory) {
        macrosURL = directory.appendingPathComponent("macros.json")
        scriptsURL = directory.appendingPathComponent("scripts.json")
        load()
    }

    func save(macro: Macro) {
        if let idx = macros.firstIndex(where: { $0.id == macro.id }) {
            macros[idx] = macro
        } else {
            macros.append(macro)
        }
        persist()
    }

    func delete(macro: Macro) {
        macros.removeAll { $0.id == macro.id }
        persist()
    }

    func save(script: Script) {
        if let idx = scripts.firstIndex(where: { $0.id == script.id }) {
            scripts[idx] = script
        } else {
            scripts.append(script)
        }
        persistScripts()
    }

    func delete(script: Script) {
        scripts.removeAll { $0.id == script.id }
        persistScripts()
    }

    private func load() {
        macros = (try? JSONDecoder().decode([Macro].self, from: Data(contentsOf: macrosURL))) ?? []
        scripts = (try? JSONDecoder().decode([Script].self, from: Data(contentsOf: scriptsURL))) ?? []
    }

    private func persist() {
        try? JSONEncoder().encode(macros).write(to: macrosURL, options: .atomic)
    }

    private func persistScripts() {
        try? JSONEncoder().encode(scripts).write(to: scriptsURL, options: .atomic)
    }
}

private extension URL {
    static var applicationSupportDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("KeyClean")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
}
