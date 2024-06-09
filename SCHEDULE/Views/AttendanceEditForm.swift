import SwiftUI

struct AttendanceEditForm: View {
    var date: String
    var group: String
    var statementId: Int
    @StateObject private var viewModel: AttendanceEditViewModel
    @Environment(\.presentationMode) var presentationMode

    init(date: String, group: String, statementId: Int, attendances: [AttendanceForCreateOrEditDTO]) {
        self.date = date
        self.group = group
        self.statementId = statementId
        _viewModel = StateObject(wrappedValue: AttendanceEditViewModel(attendances: attendances))
    }

    var body: some View {
        VStack {
            Text("Дата посещаемости: \(date)")
                .font(.title2)
                .padding()
            Text("Студенты группы: \(group)")
                .font(.title2)
                .padding()
            Text("Подгруппа: \(viewModel.attendances.first?.studentSubgroup ?? 0)")
                .font(.title3)
                .padding()

            HStack {
                Text("ФИО")
                    .multilineTextAlignment(.center)
                    .frame(width: 170)
                Spacer()
                Text("Статус")
                    .multilineTextAlignment(.center)
                    .frame(width:150)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)

                ForEach($viewModel.attendances) { $attendance in
                    HStack {
                        Text(attendance.studentFullName)
                            .multilineTextAlignment(.leading)
                            .frame(width: 170)
                        Spacer()

                        Picker(selection: $attendance.attendanceStatus, label: Text("")) {
                            ForEach(AttendanceStatus.allCases) { status in
                                Text(status.shortName).tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width:150)
                    }
                    .padding()
                }
            Button("Сохранить") {
                viewModel.saveAttendances(statementId: statementId, date: date)
                presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .foregroundColor(.blue)
                        .background(RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        )
                        .stroke(.blue, lineWidth: 2))
                        .padding(.top)
        }
        .navigationBarTitle("Изменить посещаемость", displayMode: .inline)
    }
}
