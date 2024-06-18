import SwiftUI

struct AttendanceCreateForm: View {
    var group: String
    var statementId: Int
    @ObservedObject var viewModel: AttendanceCreateViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()
    @State private var selectedTime = "08:00"
    @State private var showStatusPicker: Bool = false
    @State private var selectedAttendance: AttendanceForCreateOrEditDTO?

    init(group: String, statementId: Int, viewModel: AttendanceCreateViewModel) {
        self.group = group
        self.statementId = statementId
        self.viewModel = viewModel
    }
    
    var scheduleHours = ["08:00", "09:30", "11:00", "13:00", "14:30", "16:00", "17:30", "19:00", "20:30"]

    var body: some View {
        VStack {
            HStack {
                DatePicker("Дата посещаемости", selection: $date, displayedComponents: [.date])
                    .labelsHidden()
                
                Picker("Время", selection: $selectedTime) {
                    ForEach(scheduleHours, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                .pickerStyle(MenuPickerStyle())
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

            ForEach($viewModel.attendances, id: \.studentId) { $attendance in
                if(viewModel.subgroup == 0 || viewModel.subgroup == attendance.studentSubgroup) {
                    HStack {
                        Text(attendance.studentFullName)
                            .multilineTextAlignment(.leading)
                            .frame(width: 170)
                        Spacer()

                        Text(attendance.attendanceStatus.shortName)
                                                    .onTapGesture(count: 2) {
                                                        if attendance.attendanceStatus == .PRESENT {
                                                            attendance.attendanceStatus = .ABSENT
                                                        } else {
                                                            attendance.attendanceStatus = .PRESENT
                                                        }
                                                    }
                                                Button(action: {
                                                    selectedAttendance = attendance
                                                    showStatusPicker.toggle()
                                                }) {
                                                    Image(systemName: "chevron.down")
                                                }
                    }
                    .padding()
                }
            }
            
            Button("Сохранить") {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let formattedDate = dateFormatter.string(from: date)
                let formattedDateTime = "\(formattedDate)T\(selectedTime)"
                
                viewModel.saveAttendances(statementId: statementId, saveDate: formattedDateTime)
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
        .onAppear {
            viewModel.getStudents(group: group, statement: statementId)
        }
        .onChange(of: viewModel.changed) { _ in
            presentationMode.wrappedValue.dismiss()
        }
        .navigationBarTitle("Создать посещаемость", displayMode: .inline)
        .actionSheet(isPresented: $showStatusPicker) {
                    ActionSheet(
                        title: Text("Изменить статус"),
                        buttons: AttendanceStatus.allCases.map { status in
                            .default(Text(status.shortName)) {
                                if let selected = selectedAttendance {
                                    if let index = viewModel.attendances.firstIndex(where: { $0.studentId == selected.studentId }) {
                                        viewModel.attendances[index].attendanceStatus = status
                                    }
                                }
                            }
                        } + [.cancel()]
                    )
                }
    }
}
