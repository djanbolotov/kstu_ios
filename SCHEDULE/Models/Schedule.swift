import Foundation

struct ScheduleResponse: Codable {
    let schedules: [Schedule]
    let selectedYear: String
    let selectedSemester: String
    let daysOfWeek: [DaysOfWeek]
    let years: [String]
}

struct Schedule: Codable {
    let id: Int
    let dayOfWeek: DaysOfWeek
    let teacher: String
    let startTime: String
    let endTime: String
    let discipline: DisciplineDTO
    let group: String
}

enum DaysOfWeek: String, Codable, Equatable {
    case MONDAY = "MONDAY"
    case TUESDAY = "TUESDAY"
    case WEDNESDAY = "WEDNESDAY"
    case THURSDAY = "THURSDAY"
    case FRIDAY = "FRIDAY"
    case SATURDAY = "SATURDAY"

    var shortName: String {
        switch self {
        case .MONDAY:
            return "Пн"
        case .TUESDAY:
            return "Вт"
        case .WEDNESDAY:
            return "Ср"
        case .THURSDAY:
            return "Чт"
        case .FRIDAY:
            return "Пт"
        case .SATURDAY:
            return "Сб"
        }
    }
}
