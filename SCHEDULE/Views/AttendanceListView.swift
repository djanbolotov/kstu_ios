import SwiftUI

struct AttendanceListView: View {
    let token: String
    @ObservedObject var viewModel: AttendanceListViewModel
    @State private var searchQuery: String = ""

    init(token: String) {
        self.token = token
        self.viewModel = AttendanceListViewModel(token: token)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                if viewModel.attendanceListResponse != nil {
                    Text("Посещаемость студентов")
                        .frame(maxWidth: .infinity)
                        .font(.title)
                        .multilineTextAlignment(.center)
                } else {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                }

                if let attendanceList = viewModel.attendanceListResponse {
                    HStack {
                        Spacer()
                        Text("Учебный год:")
                        Spacer()
                        Picker(selection: $viewModel.selectedYear, label: Text("Учебный год")) {
                            ForEach(attendanceList.years, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: viewModel.selectedYear) { newValue in
                            print("changed selected year")
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
                    .onChange(of: viewModel.selectedSemester) { newValue in
                        print("changed selected semester")
                        viewModel.fetchAttendanceData()
                    }
                    
                    if !viewModel.selectedDiscipline.isEmpty {
                        HStack {
                            Spacer()
                            Text("Дисциплина:")
                            Spacer()
                            Picker(selection: $viewModel.selectedDiscipline, label: Text("Дисциплина")) {
                                ForEach(attendanceList.disciplines, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: viewModel.selectedDiscipline) { newValue in
                                print("changed selected discipline")
                                viewModel.fetchAttendanceData()
                            }
                            Spacer()
                        }
                        .padding(.top)
                        
                        if(!viewModel.selectedGroup.isEmpty) {
                            HStack {
                                Spacer()
                                Text("Группа:")
                                Spacer()
                                Picker(selection: $viewModel.selectedGroup, label: Text("Группа")) {
                                    ForEach(attendanceList.groups, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: viewModel.selectedGroup) { newValue in
                                    print("changed selected group")
                                    viewModel.fetchAttendanceData()
                                }
                                Spacer()
                            }
                            .padding(.top)
                        
                        
                        HStack {
                            Text("Дата")
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                            Spacer()
                            Text("Просмотр")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("Изменить")
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("Удалить")
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                            NavigationLink(destination: AttendanceCreateForm(group: viewModel.selectedGroup, statementId: viewModel.attendanceListResponse!.statementId!, viewModel: AttendanceCreateViewModel())) {
                                                            Text("Создать новую посещаемость")
                                                                .padding()
                                                                .foregroundColor(.blue)
                                                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.blue, lineWidth: 2))
                                                                .padding(.top)
                                                        }
                            
                        if(!attendanceList.attendancesWithSameDates!.isEmpty){
                            TextField("Поиск...", text: $searchQuery)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        let filteredAttendances = attendanceList.attendancesWithSameDates?.filter { subject in
                            searchQuery.isEmpty || subject.date.localizedCaseInsensitiveContains(searchQuery)
                        } ?? []
                        
                        if(viewModel.attendanceListResponse?.statementId != nil) {
                            if !filteredAttendances.isEmpty {
                                ForEach(filteredAttendances, id: \.date) { subject in
                                    HStack {
                                        Text(subject.date)
                                            .frame(width: 100)
                                        Spacer()
                                        NavigationLink(destination: AttendanceListDetailView(date: subject.date, group: viewModel.selectedGroup, attendances: subject.attendances)) {
                                            Image(systemName: "eye")
                                        }
                                        Spacer()
                                        NavigationLink(destination: AttendanceEditForm(date: subject.date, group: viewModel.selectedGroup, statementId: viewModel.attendanceListResponse!.statementId! ,attendances: subject.attendances)) {
                                            Image(systemName: "square.and.pencil")
                                        }
                                        Spacer()
                                        Button(action: {
                                            viewModel.deleteAttendance(statementId: (viewModel.attendanceListResponse?.statementId)!, date: subject.date)
                                            }) {
                                                Image(systemName: "trash")
                                            }
                                    }
                                    .padding()
                                }
                            } else {
                                Text("Нет данных для отображения!")
                                    .font(.title2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        }else {
                            Text("Нет данных для отображения!")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        Text("Нет данных для отображения!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Нет данных для отображения!")
                        .multilineTextAlignment(.center)
                }
            }.onAppear(){
                viewModel.fetchAttendanceData()
            }
        }
    }
}
