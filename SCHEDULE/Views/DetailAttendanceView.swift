import SwiftUI

struct DetailedAttendanceView: View {
    let attendanceDetails: AttendancesWithDisciplines

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CalendarView(attendanceDetails: attendanceDetails.attendances ?? [])
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Кол-во посещений: \(attendanceDetails.countOfAttendance ?? 0) закрашено ")
                        Circle()
                            .fill(.green)
                            .frame(width: 20, height: 20)
                    }
                    HStack {
                        Text("Кол-во отсутствий: \((attendanceDetails.countOfLessons ?? 0) - (attendanceDetails.countOfAttendance ?? 0)) закрашено ")
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                    }
                    let lates = attendanceDetails.attendances?.filter { $0.attendanceStatus == .LATE }.count ?? 0
                    HStack {
                        Text("Кол-во опозданий: \(lates) закрашено ")
                        Circle()
                            .fill(.yellow)
                            .frame(width: 20, height: 20)
                    }
                    Text("Процент посещаемости: \(String(format: "%.2f", attendanceDetails.percentageOfAttendance ?? 0.0))%")
                }
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Детали посещаемости")
    }
}
