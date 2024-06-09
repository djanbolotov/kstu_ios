//
//  StudentAttendance.swift
//  SCHEDULE
//
//  Created by Djanbolotov Askabek on 30/5/24.
//

import Foundation

enum AttendanceStatus: String, Codable, Equatable, CaseIterable, Identifiable {
    var id: Self { self }
    case PRESENT = "PRESENT"
    case ABSENT = "ABSENT"
    case LATE = "LATE"
    
    var shortName: String {
        switch self {
        case .PRESENT:
            return "Присутствует"
        case .ABSENT:
            return "Отсутствует"
        case .LATE:
            return "Опоздал"
        }
    }
}

struct AttendanceDTO: Identifiable, Codable {
    let id: Int
    let attendanceStatus: AttendanceStatus
    let attendanceDate: String
}

struct AttendancesWithDisciplines: Codable {
    let discipline: DisciplineDTO
    let attendances: [AttendanceDTO]?
    let countOfLessons: Int?
    let countOfAttendance: Int?
    let percentageOfAttendance: Double?
}

struct StudentAttendanceStatisticResponse: Codable {
    let attendancesWithDisciplines: [AttendancesWithDisciplines]?
    let selectedYear: String
    let selectedSemester: String
    let years: [String]
}
