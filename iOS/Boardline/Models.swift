import Foundation

struct BoardingEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var startDate: Date
    var endDate: Date
    var location: String
    var sitterContact: String
    var createdAt: Date = Date()
}
