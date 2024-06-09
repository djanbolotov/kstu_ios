import SwiftUI

struct TeacherProfileView: View {
    let token: String
    @ObservedObject var viewModel: TeacherStatementViewModel
    
    init(token: String) {
        self.token = token
        self.viewModel = TeacherStatementViewModel(token: token)
    }
    
    var body: some View {
        VStack {
            Image(systemName: "person.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding()
            
            if let teacherStatement = viewModel.teacherStatement {
                Text("\(teacherStatement.firstName) \(teacherStatement.lastName)")
                    .fontWeight(.bold)
                    .padding()
                
                HStack {
                    Text("Учебный год:")
                    Picker(selection: $viewModel.year, label: Text("Учебный год")) {
                        ForEach(teacherStatement.years, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 140)
                    .onChange(of: viewModel.year) { newValue in
                        viewModel.fetchTeacherStatements()
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
                        viewModel.fetchTeacherStatements()
                    }
                }
                .padding(.top)
                
                Text("Преподаваемые предметы:")
                    .padding()
                
                if(teacherStatement.disciplines.count > 0) {
                    List(teacherStatement.disciplines) { discipline in
                        Text(discipline.name)
                    }
                    .padding()
                } else {
                    Text("Преподаваемых предметов за этот семестр отсутствуют!")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            }else {
                Text("Нет данных для отображения!")
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            viewModel.fetchTeacherStatements()
        }
    }
}
