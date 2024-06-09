//
//  File.swift
//  SCHEDULE
//
//  Created by Djanbolotov Askabek on 27/5/24.
//

import Foundation

enum Role: String, Codable, Equatable {
    case student = "STUDENT"
    case teacher = "TEACHER"
    case admin = "ADMIN"
}

struct DisciplineDTO:  Identifiable, Codable {
    let id: Int
    let name: String
}

struct StudentStatementResponse: Codable {
    let firstName: String
    let lastName: String
    let group: String
    let selectedYear: String
    let selectedSemester: String
    let years: [String]
    let disciplines: [DisciplineDTO]
}

struct TeacherStatementResponse: Codable {
    let firstName: String
    let lastName: String
    let selectedYear: String
    let selectedSemester: String
    let years: [String]
    let disciplines: [DisciplineDTO]
}

