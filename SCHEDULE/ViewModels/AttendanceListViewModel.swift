import Foundation
import Combine

class AttendanceListViewModel: ObservableObject {
    @Published var selectedYear: String = ""
    @Published var selectedSemester: String = ""
    @Published var selectedDiscipline: String = ""
    @Published var selectedGroup: String = ""
    @Published var attendanceListResponse: AttendanceListForTeacherResponse?

    private var cancellables = Set<AnyCancellable>()
    private let token: String
    
    init(token: String) {
        self.token = token
    }

    func deleteAttendance(statementId: Int, date: String) {
        var urlComponents = URLComponents(string: "http://localhost:8080/api/attendance/delete/\(statementId)")!
        var queryItems = [URLQueryItem]()
        
        if !selectedDiscipline.isEmpty {
            queryItems.append(URLQueryItem(name: "date", value: date))
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
                        .map { String(data: $0, encoding: .utf8) ?? "Unknown response" } // convert data to String
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print("Error fetching data: \(error)")
                            }
                        }, receiveValue: { response in
                            print("RESPONSE IS: ", response)
                            if response == "deleted" {
                                // Handle successful deletion if needed
                                print("Attendance successfully deleted.")
                                self.fetchAttendanceData()
                            }
                        })
            .store(in: &cancellables)
    }
    func fetchAttendanceData() {
        var urlComponents = URLComponents(string: "http://localhost:8080/api/attendance/teacher/list")!
        var queryItems = [URLQueryItem]()
        
        if !selectedDiscipline.isEmpty {
            queryItems.append(URLQueryItem(name: "discipline", value: selectedDiscipline))
        }
        if !selectedGroup.isEmpty {
            queryItems.append(URLQueryItem(name: "group", value: selectedGroup))
        }
        if !selectedYear.isEmpty {
            queryItems.append(URLQueryItem(name: "year", value: selectedYear))
        }
        if !selectedSemester.isEmpty {
            queryItems.append(URLQueryItem(name: "semester", value: selectedSemester))
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
            .decode(type: AttendanceListForTeacherResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.attendanceListResponse = response
                self?.selectedYear = response.selectedYear
                self?.selectedSemester = response.selectedSemester
                self?.selectedDiscipline = response.selectedDiscipline ?? ""
                self?.selectedGroup = response.selectedGroup ?? ""
            })
            .store(in: &cancellables)
    }
}

