import SwiftUI

struct StudentListAttendanceView: View {
    var groupName: String
    var discipline: DisciplineDTO
    var attendancesWithGroup: AttendancesWithDisciplinesAndGroups
    
    @State private var selectedGroupName: String?

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("Посещаемость студентов")
                .frame(maxWidth: .infinity)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.vertical, 10)
            HStack {
                Text("Студент")
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
                Spacer()
                Text("Кол-во занятий")
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Кол-во посещений")
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Процент (%)")
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)

            ScrollView {
                VStack {
                    if(!(attendancesWithGroup.attendances?.isEmpty ?? true)) {
                        ForEach(attendancesWithGroup.studentNames(), id: \.self) { student in
                            NavigationLink(destination: DetailedAttendanceView(attendanceDetails: AttendancesWithDisciplines(discipline: discipline, attendances: attendancesWithGroup.attendanceForEachStudent(studentFullName: student), countOfLessons: attendancesWithGroup.attendanceForEachStudent(studentFullName: student).count, countOfAttendance: attendancesWithGroup.attendanceForEachStudent(studentFullName: student).filter { $0.attendanceStatus == .PRESENT }.count, percentageOfAttendance: Double(attendancesWithGroup.attendanceForEachStudent(studentFullName: student).filter { $0.attendanceStatus == .PRESENT }.count) / Double(attendancesWithGroup.attendanceForEachStudent(studentFullName: student).count) * 100) )) {
                                StudentListAttendanceRow(
                                    studentFullName: student,
                                    attendances: attendancesWithGroup.attendanceForEachStudent(studentFullName: student)
                                )
                            }
                        }
                    } else {
                        Text("Записи отсутствуют!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .navigationTitle(groupName)
    }
}

struct StudentListAttendanceRow: View {
    var studentFullName: String
    var attendances: [AttendanceDTO]

    var body: some View {
        let totalLessons = attendances.count
        let attendanceCount = attendances.filter { $0.attendanceStatus == .PRESENT }.count
        let attendancePercentage = totalLessons != 0 ? Double(attendanceCount) / Double(totalLessons) * 100 : 0.0
        
        return HStack {
                Text(studentFullName)
                    .frame(width: 100)
                Spacer()
                Text("\(totalLessons)")
                Spacer()
                Text("\(attendanceCount)")
                Spacer()
                Text(String(format: "%.2f", attendancePercentage))
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
        }
}
