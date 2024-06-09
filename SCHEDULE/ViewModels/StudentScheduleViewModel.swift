import Foundation
import Combine

class StudentScheduleViewModel: ObservableObject {
    @Published var scheduleResponse: ScheduleResponse?
    @Published var selectedYear = ""
    @Published var selectedSemester = ""
    @Published var selectedDayOfWeek = 0
    @Published var daysOfWeek: [DaysOfWeek] = [.MONDAY, .TUESDAY, .WEDNESDAY, .THURSDAY, .FRIDAY, .SATURDAY]

    private var cancellables = Set<AnyCancellable>()
    private let token: String

    init(token: String) {
        self.token = token
        fetchSchedule()
        setTodayAsSelectedDay()
    }

    func fetchSchedule() {
        var urlComponents = URLComponents(string: "http://localhost:8080/api/schedule/student")!
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
            .decode(type: ScheduleResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching student schedule: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.scheduleResponse = response
                self?.selectedYear = response.selectedYear
                self?.selectedSemester = response.selectedSemester
            })
            .store(in: &cancellables)
    }
    
    func setTodayAsSelectedDay() {
        let calendar = Calendar.current
        let currentWeekday = calendar.component(.weekday, from: Date())
        
        switch currentWeekday {
        case 1:
            selectedDayOfWeek = 0 // Monday
        case 2...7:
            selectedDayOfWeek = currentWeekday - 2
        default:
            selectedDayOfWeek = 0
        }
    }
    
    func schedulesForSelectedDay() -> [Schedule] {
        guard selectedDayOfWeek < daysOfWeek.count else { return [] }
        let selectedDay = daysOfWeek[selectedDayOfWeek]
        return scheduleResponse?.schedules.filter { $0.dayOfWeek == selectedDay } ?? []
    }
}
