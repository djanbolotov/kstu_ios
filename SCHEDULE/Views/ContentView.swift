import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        Group {
            if let token = viewModel.token {
                HomeView(token: token)
            } else {
                LoginView(viewModel: viewModel)
            }
        }
    }
}

struct HomeView: View {
    let token: Token
    
    var body: some View {
        TabView {
            if token.role == .student {
                StudentAttendanceView(token: token.token)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Дом")
                    }
                
                StudentScheduleView(token: token.token)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Расписание")
                    }
                
                StudentProfileView(token: token.token)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Профиль")
                    }
            } else {
                TeacherAttendanceView(token: token.token)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Дом")
                    }
                AttendanceListView(token: token.token)
                    .tabItem {
                        Image(systemName: "square.and.pencil")
                        Text("Создать")
                    }
                TeacherScheduleView(token: token.token)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Расписание")
                    }
                
                TeacherProfileView(token: token.token)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Профиль")
                    }
            }
        }
        .padding()
    }
}
