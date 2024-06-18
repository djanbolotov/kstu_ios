import Foundation
import Combine

class AttendanceCreateViewModel: ObservableObject {
    @Published var attendances: [AttendanceForCreateOrEditDTO] = []
    @Published var subgroups: [Int] = [0,1, 2]
    @Published var subgroup: Int = 0
    @Published var changed: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func saveAttendances(statementId: Int, saveDate: String) {
        let url = URL(string: "http://localhost:8080/api/attendance/save")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let filteredAttendances: [AttendanceForCreateOrEditDTO]
                if subgroup == 0 {
                    filteredAttendances = attendances
                } else {
                    filteredAttendances = attendances.filter { $0.studentSubgroup == subgroup }
                }
        let attendanceRequest = AttendanceRequest(statementId: statementId, date: "\(saveDate):00.000000", attendances: filteredAttendances)
        do {
            let jsonData = try JSONEncoder().encode(attendanceRequest)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    print("Server Error: \(httpResponse.statusCode)")
                    return
                }
                
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8)
                    self.changed = true
                }
            }
            task.resume()
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
        }
    }
    
    func getStudents(group: String, statement: Int) {
        var urlComponents = URLComponents(string: "http://localhost:8080/api/attendance/create/student-list")!
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "group", value: group))
        queryItems.append(URLQueryItem(name: "statementId", value: "\(statement)"))
        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [AttendanceForCreateOrEditDTO].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching student statements: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.attendances = response
            })
            .store(in: &cancellables)
    }
}
