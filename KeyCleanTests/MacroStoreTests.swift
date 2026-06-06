import XCTest
@testable import KeyClean

final class MacroStoreTests: XCTestCase {
    var tempDir: URL!
    var store: MacroStore!

    override func setUp() {
        super.setUp()
        tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        store = MacroStore(directory: tempDir)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDir)
        super.tearDown()
    }

    func test_saveMacro_persistsAndLoads() throws {
        let macro = Macro(id: UUID(), name: "Test", events: [], hotkey: nil)
        store.save(macro: macro)
        let fresh = MacroStore(directory: tempDir)
        XCTAssertEqual(fresh.macros.count, 1)
        XCTAssertEqual(fresh.macros[0].id, macro.id)
        XCTAssertEqual(fresh.macros[0].name, "Test")
    }

    func test_deleteMacro_removesFromStore() {
        let macro = Macro(id: UUID(), name: "Delete Me", events: [], hotkey: nil)
        store.save(macro: macro)
        store.delete(macro: macro)
        let fresh = MacroStore(directory: tempDir)
        XCTAssertTrue(fresh.macros.isEmpty)
    }

    func test_saveScript_persistsAndLoads() throws {
        let script = Script(id: UUID(), name: "S", source: "keyboard.type('hi')", hotkey: nil)
        store.save(script: script)
        let fresh = MacroStore(directory: tempDir)
        XCTAssertEqual(fresh.scripts.count, 1)
        XCTAssertEqual(fresh.scripts[0].source, "keyboard.type('hi')")
    }

    func test_corruptMacrosFile_resetsToEmpty() throws {
        let macrosURL = tempDir.appendingPathComponent("macros.json")
        try "not json at all".write(to: macrosURL, atomically: true, encoding: .utf8)
        let store = MacroStore(directory: tempDir)
        XCTAssertTrue(store.macros.isEmpty)
    }
}
