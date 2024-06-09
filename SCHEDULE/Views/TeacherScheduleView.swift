import SwiftUI

struct TeacherScheduleView: View {
    let token: String
    @ObservedObject var viewModel: TeacherScheduleViewModel

    init(token: String) {
        self.token = token
        self.viewModel = TeacherScheduleViewModel(token: token)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if (viewModel.scheduleResponse != nil) {
                Text("Расписание преподавателя")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "calendar.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            
            if let teacherSchedule = viewModel.scheduleResponse {
                HStack {
                    Spacer()
                    Text("Учебный год:")
                    Picker(selection: $viewModel.selectedYear, label: Text("Учебный год")) {
                        ForEach(teacherSchedule.years, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 140)
                    .onChange(of: viewModel.selectedYear) { newValue in
                        viewModel.fetchSchedule()
                    }
                    .padding(.top)
                }
                .padding(.top)

                Picker(selection: $viewModel.selectedSemester, label: Text("Полугодие")) {
                    ForEach(["Весенний семестр", "Осенний семестр"], id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: viewModel.selectedSemester) { newValue in
                    viewModel.fetchSchedule()
                }
                .padding(.top)

                Picker(selection: $viewModel.selectedDayOfWeek, label: Text("День недели")) {
                    ForEach(0..<viewModel.daysOfWeek.count, id: \.self) { index in
                        Text(viewModel.daysOfWeek[index].shortName).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                VStack(alignment: .leading) {
                    if(viewModel.schedulesForSelectedDay().count > 0){
                        ForEach(viewModel.schedulesForSelectedDay(), id: \.id) { schedule in
                            Text("\(schedule.discipline.name) (\(schedule.startTime) - \(schedule.endTime)) \(schedule.group)")
                        }
                    } else {
                        Text("Расписание на этот день отсутвтвует! Можно отдыхать)")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                }
            }else {
                Text("Нет данных для отображения!")
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .onAppear {
            viewModel.setTodayAsSelectedDay()
        }
    }
}

struct TeacherScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        TeacherScheduleView(token: "your-token-here")
    }
}
