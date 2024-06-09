import Foundation

class LoginViewModel: ObservableObject {
    @Published var username = "" {
        didSet {
            clearErrorMessage()
        }
    }
    @Published var password = "" {
        didSet {
            clearErrorMessage()
        }
    }
    @Published var errorMessage = ""
    @Published var token: Token?
    @Published var isLoading = false
    
    init() {}
    
    func login() {
        guard validate() else {
            return
        }
        
        isLoading = true

        Task {
            do {
                let receivedToken = try await getUser()
                DispatchQueue.main.async {
                    self.token = receivedToken
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Неверный логин или пароль!"
                    self.isLoading = false
                }
            }
        }
    }

    func getUser() async throws -> Token {
        let endpoint = "http://localhost:8080/api/login"
        guard let url = URL(string: endpoint) else { throw GHError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body: [String: String] = ["username": username, "password": password]
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Token.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
    
    func validate() -> Bool {
        errorMessage = ""
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Заполните все поля!"
            return false
        }
        return true
    }
    
    private func clearErrorMessage() {
        errorMessage = ""
    }
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct Token: Codable, Equatable {
    var token: String
    let role: Role
}
