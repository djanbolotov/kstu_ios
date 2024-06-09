import Foundation

struct TeacherAttendanceStatisticResponse: Codable {
    let attendancesWithDisciplines: [AttendancesWithDisciplinesAndGroups]?
    let selectedYear: String
    let selectedSemester: String
    let years: [String]
    
    func groupedAndSummed() -> [AttendancesWithDisciplinesAndGroups] {
            guard let attendancesWithDisciplines = attendancesWithDisciplines else { return [] }
            
            var grouped = [Int: AttendancesWithDisciplinesAndGroups]()
            
            for attendanceGroup in attendancesWithDisciplines {
                let statementId = attendanceGroup.statementId
                
                if var existingGroup = grouped[statementId] {
                    existingGroup.countOfLessons = (existingGroup.countOfLessons ?? 0) + (attendanceGroup.countOfLessons ?? 0)
                    existingGroup.countOfAttendance = (existingGroup.countOfAttendance ?? 0) + (attendanceGroup.countOfAttendance ?? 0)
                    existingGroup.percentageOfAttendance = ((existingGroup.percentageOfAttendance ?? 0.0) + (attendanceGroup.percentageOfAttendance ?? 0.0)) / 2
                    grouped[statementId] = existingGroup
                } else {
                    grouped[statementId] = attendanceGroup
                }
            }
            
            return Array(grouped.values)
        }
}

struct AttendancesWithDisciplinesAndGroups: Codable {
    let discipline: DisciplineDTO
    let attendances: [AttendanceForTeacherDTO]?
    let statementId: Int
    let groupName: String
    var countOfLessons: Int?
    var countOfAttendance: Int?
    var percentageOfAttendance: Double?
    
    func attendanceForEachStudent(studentFullName: String) -> [AttendanceDTO] {
            guard let attendances = attendances else { return [] }
            
            return attendances
                .filter { $0.studentFullName == studentFullName }
                .map { AttendanceDTO(id: $0.id, attendanceStatus: $0.attendanceStatus, attendanceDate: $0.attendanceDate) }
    }
    
    func studentNames() -> [String] {
            guard let attendances = attendances else { return [] }
            
            let studentNames = attendances.map { $0.studentFullName }
            return Array(Set(studentNames)).sorted()
    }
}

struct AttendanceForTeacherDTO: Identifiable, Codable {
    let id: Int
    let attendanceStatus: AttendanceStatus
    let studentFullName: String
    let attendanceDate: String
}


