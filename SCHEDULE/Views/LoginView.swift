import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            
            Text("Посещаемость студента")
                .font(.title)
                .multilineTextAlignment(.center)
                .bold()
                .padding()
            
            Image(systemName: "person.fill.checkmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding()
            
            Text("КГТУ кафедра ПОКС")
                .font(.headline)
                .padding()
            
            Form {
                TextField("Логин", text: $viewModel.username)
                    .autocapitalization(.none)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Пароль", text: $viewModel.password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Spacer()
                    Button(viewModel.isLoading ? "Загрузка..." : "Войти") {
                        viewModel.login()
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isLoading ? Color.gray : Color.blue)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                    Spacer()
                }
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
