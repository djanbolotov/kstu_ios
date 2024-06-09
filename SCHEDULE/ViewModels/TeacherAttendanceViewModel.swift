import Foundation
import Combine

class TeacherAttendanceViewModel: ObservableObject {
    @Published var selectedYear: String = ""
    @Published var selectedSemester: String = ""
    @Published var teacherAttendanceStatisticResponse: TeacherAttendanceStatisticResponse?
    @Published var attendancesWithDisciplines: [AttendancesWithDisciplinesAndGroups] = []

    private var cancellables = Set<AnyCancellable>()
    private let token: String
    
    init(token: String) {
        self.token = token
        fetchAttendanceData()
    }

    func fetchAttendanceData() {
        var urlComponents = URLComponents(string: "http://localhost:8080/api/attendance/teacher")!
        var queryItems = [URLQueryItem]()
        
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
            .decode(type: TeacherAttendanceStatisticResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.teacherAttendanceStatisticResponse = response
                self?.selectedYear = response.selectedYear
                self?.selectedSemester = response.selectedSemester
                
                if let groupedData = response.groupedAndSummed() as? [AttendancesWithDisciplinesAndGroups] {
                                    self?.attendancesWithDisciplines = groupedData
                                }
            })
            .store(in: &cancellables)
    }
}

