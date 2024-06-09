import Foundation
import Combine

class TeacherStatementViewModel: ObservableObject {
    @Published var year = ""
    @Published var semester = ""
    @Published var teacherStatement: TeacherStatementResponse?
    
    private var cancellables = Set<AnyCancellable>()
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func fetchTeacherStatements() {
        var urlComponents = URLComponents(string: "http://localhost:8080/api/statements/teacher")!
        var queryItems = [URLQueryItem]()
        
        if !year.isEmpty {
            queryItems.append(URLQueryItem(name: "year", value: year))
        }
        if !semester.isEmpty {
            queryItems.append(URLQueryItem(name: "semester", value: semester))
        }
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: TeacherStatementResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching teacher statements: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.teacherStatement = response
                self?.year = response.selectedYear
                self?.semester = response.selectedSemester
            })
            .store(in: &cancellables)
    }
}
