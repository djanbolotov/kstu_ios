import SwiftUI

struct TeacherAttendanceView: View {
    let token: String
    @ObservedObject var viewModel: TeacherAttendanceViewModel

    init(token: String) {
        self.token = token
        self.viewModel = TeacherAttendanceViewModel(token: token)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                if viewModel.teacherAttendanceStatisticResponse != nil {
                    Text("Посещаемость студентов")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .multilineTextAlignment(.center)
                } else {
                    Image(systemName: "house.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }

                if let teacherAttendance = viewModel.teacherAttendanceStatisticResponse {
                    HStack {
                        Spacer()
                        Text("Учебный год:")
                        Spacer()
                        Picker(selection: $viewModel.selectedYear, label: Text("Учебный год")) {
                            ForEach(teacherAttendance.years, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: viewModel.selectedYear) { _ in
                            viewModel.fetchAttendanceData()
                        }
                        Spacer()
                    }
                    .padding(.top)

                    Picker(selection: $viewModel.selectedSemester, label: Text("Полугодие")) {
                        ForEach(["Весенний семестр", "Осенний семестр"], id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: viewModel.selectedSemester) { _ in
                        viewModel.fetchAttendanceData()
                    }

                    HStack {
                        Text("Дисциплина")
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

                    if (!viewModel.attendancesWithDisciplines.isEmpty) {
                        ForEach(viewModel.attendancesWithDisciplines, id: \.discipline.id) { subject in
                            NavigationLink(destination: GroupAttendanceView(
                                                        discipline: subject.discipline,
                                                        attendancesWithGroups:
                                                        viewModel.teacherAttendanceStatisticResponse!.attendancesWithDisciplines!.filter { $0.discipline.id == subject.discipline.id }
                                                           )
                                                       ){
                                HStack {
                                    Text(subject.discipline.name)
                                        .frame(width: 100)
                                    Spacer()
                                    Text("\(subject.countOfLessons ?? 0)")
                                    Spacer()
                                    Text("\(subject.countOfAttendance ?? 0)")
                                    Spacer()
                                    Text(String(format: "%.2f", subject.percentageOfAttendance ?? 0.00))
                                }
                                .padding()
                            }
                            Divider()

                        }
                    } else {
                        Text("Зарегистрированных предметов за этот семестр нету!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Нет данных для отображения!")
                        .multilineTextAlignment(.center)
                }
            }
            .onAppear {
                viewModel.fetchAttendanceData()
            }
        }
    }
}
