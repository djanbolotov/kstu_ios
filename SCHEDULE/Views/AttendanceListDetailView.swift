import SwiftUI

struct AttendanceListDetailView: View {
    var date: String
    var group: String
    var attendances: [AttendanceForCreateOrEditDTO]

    var body: some View {
        VStack {
            Text("Дата посещаемости: \(date)")
                .font(.title2)
                .padding()
            Text("Студенты группы: \(group)")
                .font(.title2)
                .padding()

            HStack {
                Text("ФИО")
                    .multilineTextAlignment(.center)
                    .frame(width: 170)
                Spacer()
                Text("Статус")
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Подгруппа")
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            
            ForEach(attendances, id: \.id) { attendance in
                HStack {
                    Text(attendance.studentFullName)
                        .multilineTextAlignment(.leading)
                        .frame(width: 170)
                    Text(attendance.attendanceStatus.shortName)
                        .multilineTextAlignment(.center)
                    Text("\(attendance.studentSubgroup ?? 0)")
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .navigationBarTitle("Детали посещаемости", displayMode: .inline)
    }
}
