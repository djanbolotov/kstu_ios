import SwiftUI

struct GroupAttendanceView: View {
    var discipline: DisciplineDTO
    var attendancesWithGroups: [AttendancesWithDisciplinesAndGroups]
    
    @State private var selectedGroupName: String?

    var body: some View {
            VStack(alignment: .center, spacing: 0) {
                Text("Посещаемость студентов")
                    .frame(maxWidth: .infinity)
                    .font(.title)
                    .multilineTextAlignment(.center)

                Picker(selection: $selectedGroupName, label: Text("Группа")) {
                    Text("Все группы").tag(String?.none)
                    ForEach(attendancesWithGroups.compactMap { $0.groupName }, id: \.self) {
                        Text($0).tag($0 as String?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()

                HStack {
                    Text("Группа")
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
                        if let groupName = selectedGroupName {
                            if let groupAttendance = attendancesWithGroups.first(where: { $0.groupName == groupName }) {
                                NavigationLink(destination: StudentListAttendanceView(groupName: groupAttendance.groupName, discipline: discipline, attendancesWithGroup: groupAttendance)) {
                                    GroupAttendanceRow(groupAttendance: groupAttendance, discipline: discipline)
                                }
                            } else {
                                Text("Записи отсутствуют!")
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            if(!attendancesWithGroups.isEmpty) {
                                ForEach(attendancesWithGroups, id: \.groupName) { groupAttendance in
                                    NavigationLink(destination: StudentListAttendanceView(groupName: groupAttendance.groupName, discipline: discipline, attendancesWithGroup: groupAttendance)) {
                                        GroupAttendanceRow(groupAttendance: groupAttendance, discipline: discipline)
                                    }
                                }
                            } else {
                                Spacer()
                                Text("Нет данных для отображения!")
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                }
            }
    }
}

struct GroupAttendanceRow: View {
    var groupAttendance: AttendancesWithDisciplinesAndGroups
    var discipline: DisciplineDTO

    var body: some View {
        VStack {
            HStack {
                Text(groupAttendance.groupName)
                    .frame(width: 100)
                Spacer()
                Text("\(groupAttendance.countOfLessons ?? 0)")
                Spacer()
                Text("\(groupAttendance.countOfAttendance ?? 0)")
                Spacer()
                Text(String(format: "%.2f", groupAttendance.percentageOfAttendance ?? 0.00))
            }
            .padding()
            Divider()
        }
    }
}
