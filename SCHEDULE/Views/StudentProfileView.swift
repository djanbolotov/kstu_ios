import SwiftUI

struct StudentProfileView: View {
    let token: String
    @ObservedObject var viewModel: StudentStatementViewModel

    init(token: String) {
        self.token = token
        self.viewModel = StudentStatementViewModel(token: token)
    }
    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding()
            
            if let studentStatement = viewModel.studentStatement {
                Text("\(studentStatement.firstName) \(studentStatement.lastName)")
                    .fontWeight(.bold)
                    .padding()
                
                Text("Группа: \(studentStatement.group)")
                    .fontWeight(.bold)
                    .padding()
                
                HStack {
                    Text("Учебный год:")
                    Picker(selection: $viewModel.year, label: Text("Учебный год")) {
                        ForEach(studentStatement.years, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 140)
                    .onChange(of: viewModel.year) { newValue in
                        viewModel.fetchStudentStatements()
                    }
                    .padding(.top)

                }
                .padding(.top)

                HStack {
                    Picker(selection: $viewModel.semester, label: Text("Полугодие")) {
                        ForEach(["Весенний семестр", "Осенний семестр"], id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: viewModel.semester) { newValue in
                        viewModel.fetchStudentStatements()
                    }
                }
                .padding(.top)


                Text("Зарегистрированные предметы:")
                    .padding()
                
                if(studentStatement.disciplines.count > 0) {
                    List(studentStatement.disciplines) { discipline in
                        Text(discipline.name)
                    }
                    .padding()
                } else {
                    Text("Зарегистрированных предметов за этот семестр отсутствуют!")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("Нет данных для отображения!")
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            viewModel.fetchStudentStatements()
        }
    }
}
