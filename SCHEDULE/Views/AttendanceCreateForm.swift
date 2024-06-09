import SwiftUI

struct AttendanceCreateForm: View {
    var group: String
    var statementId: Int
    @ObservedObject var viewModel: AttendanceCreateViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()

    init(group: String, statementId: Int, viewModel: AttendanceCreateViewModel) {
        self.group = group
        self.statementId = statementId
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            VStack {
                        DatePicker("Дата посещаемости", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                    }
            
            Text("Студенты группы: \(group)")
                .font(.title2)
                .padding()
            HStack {
                Text("Подгруппа:")
                Picker(selection: $viewModel.subgroup, label: Text("Подгруппа")) {
                    ForEach(viewModel.subgroups, id: \.self) { subgroup in
                        if(subgroup == 0) {
                            Text("Все")
                        } else {
                            Text("\(subgroup)-ая подгруппа").tag(subgroup)
                                    .frame(width: 150)

                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 140)
                .padding(.top)

            }
            .padding(.top)

            HStack {
                Text("ФИО")
                    .multilineTextAlignment(.center)
                    .frame(width: 170)
                Spacer()
                Text("Статус")
                    .multilineTextAlignment(.center)
                    .frame(width: 150)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)

            ForEach($viewModel.attendances, id:\.studentId) { $attendance in
                if(viewModel.subgroup == 0 || viewModel.subgroup == attendance.studentSubgroup) {
                    HStack {
                        Text(attendance.studentFullName)
                            .multilineTextAlignment(.leading)
                            .frame(width: 170)
                        Spacer()

                        Picker(selection: $attendance.attendanceStatus, label: Text("")) {
                            ForEach(AttendanceStatus.allCases, id: \.self) { status in
                                Text(status.shortName).tag(status)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(width: 150)
                    }
                    .padding()
                }
            }
            
            Button("Сохранить") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-DDTHH:MM"
                let formattedDate = dateFormatter.string(from: date)
                
                viewModel.saveAttendances(statementId: statementId, date: formattedDate)
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
        .onAppear(){
            viewModel.getStudents(group: group, statement: statementId)
        }
        .onChange(of: viewModel.changed, {
            presentationMode.wrappedValue.dismiss()
        })
        .navigationBarTitle("Создать посещаемость", displayMode: .inline)
    }
}
