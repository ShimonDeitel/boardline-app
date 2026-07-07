import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 8 // seed data has 3 entries; keep this above that

    @Published var entries: [BoardingEntry] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("boardline_entries.json")
        load()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(_ entry: BoardingEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: BoardingEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: BoardingEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([BoardingEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
        BoardingEntry(startDate: Date().addingTimeInterval(-604800), endDate: Date().addingTimeInterval(-604800), location: "Sample 1", sitterContact: "Sample 1"),
        BoardingEntry(startDate: Date().addingTimeInterval(-1209600), endDate: Date().addingTimeInterval(-1209600), location: "Sample 2", sitterContact: "Sample 2"),
        BoardingEntry(startDate: Date().addingTimeInterval(-1814400), endDate: Date().addingTimeInterval(-1814400), location: "Sample 3", sitterContact: "Sample 3")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL)
        }
    }
}
