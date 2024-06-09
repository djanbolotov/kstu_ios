//
//  AttendanceListForTeacher.swift
//  SCHEDULE
//
//  Created by Djanbolotov Askabek on 31/5/24.
//

import Foundation

struct AttendanceListForTeacherResponse: Codable {
    var attendancesWithSameDates: [AttendancesWithSameDate]?
    var selectedYear: String
    var selectedSemester: String
    var selectedDiscipline: String?
    var statementId: Int?
    var selectedGroup: String?
    var years: [String]
    var groups: [String]
    var disciplines: [String]
}

struct AttendancesWithSameDate: Codable {
    var date: String
    var attendances: [AttendanceForCreateOrEditDTO]
}

struct AttendanceForCreateOrEditDTO: Codable, Identifiable {
    var id: Int?
    var attendanceStatus: AttendanceStatus
    var studentId: Int
    var studentFullName: String
    var studentSubgroup: Int?
    var attendanceDate: String
}

struct AttendanceRequest: Codable {
    var statementId: Int
    var date: String
    var attendances: [AttendanceForCreateOrEditDTO]
}
