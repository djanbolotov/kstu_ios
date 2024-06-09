import SwiftUI

struct CalendarView: View {
    let attendanceDetails: [AttendanceDTO]
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var isShowingTimeline = false
    
    private let calendar = Calendar.current
    private var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: startOfMonth) }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation {
                        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                    }
                }) {
                    Image(systemName: "chevron.left")
                }
                Text("\(monthAndYear(for: currentDate))")
                    .font(.headline)
                Button(action: {
                    withAnimation {
                        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                    }
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth, id: \.self) { date in
                    Button(action: {
                        selectedDate = date
                        isShowingTimeline = true
                    }) {
                        VStack {
                            Text(dayNumber(for: date))
                            Circle()
                                .fill(color(for: attendanceStatus(on: date)))
                                .frame(width: 20, height: 20)
                        }
                        .padding(5)
                    }
                }
            }
            
            if isShowingTimeline {
                TimelineViewModal(date: selectedDate!, attendanceDetails: attendanceDetails, isPresented: $isShowingTimeline)
                        .padding()
                        .fullScreenCover(isPresented: $isShowingTimeline) {
                            TimelineViewModal(date: selectedDate!, attendanceDetails: attendanceDetails, isPresented: $isShowingTimeline)
                }
            }

        }
    }
    
    private func monthAndYear(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
    
    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private func attendanceStatus(on date: Date) -> AttendanceStatus? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return attendanceDetails.first { $0.attendanceDate.prefix(upTo: $0.attendanceDate.firstIndex(of: "T")!) == dateString }?.attendanceStatus
    }
    
    private func color(for status: AttendanceStatus?) -> Color {
        guard let status = status else { return .clear }
        switch status {
        case .PRESENT:
            return .green
        case .ABSENT:
            return .red
        case .LATE:
            return .yellow
        }
    }
}

struct TimelineViewModal: View {
    let date: Date
    let attendanceDetails: [AttendanceDTO]
    @Binding var isPresented: Bool
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH"
        return formatter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                HStack{
                    Text("Временная линия для \(date, formatter: dateFormatter)")
                        .font(.headline)
                        .padding(.bottom, 8)
                    Button("Закрыть") {
                        isPresented = false
                    }
                }
                
                
                ForEach(0..<24) { hour in
                    ZStack{
                        HStack {
                            Text("\(hour):00")
                                .frame(width: 60, alignment: .trailing)
                            Spacer()
                        }
                        .padding(.vertical, 2)
                        .background(attendanceColor(forHour: hour))
                        .cornerRadius(4)
                        
                        if let status = attendanceStatus(forHour: hour) {
                                    Text(status.shortName)
                                        .foregroundColor(.black)
                                        .offset(x: 8)
                        }
                    }
                }
            }
            .padding(8)
        }
        .navigationBarTitle("Временная линия", displayMode: .inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray4))
        .cornerRadius(16)
        .padding(20)
    }
    
    private func attendanceStatus(forHour hour: Int) -> AttendanceStatus? {
            let hourString = String(format: "%02d", hour)
            let targetDate = dateFormatter.string(from: date) + "T" + hourString
            let targetNewDate = targetDate.prefix(upTo: targetDate.firstIndex(of: "T")!) + "T" + hourString

            let attendance = attendanceDetails.first { $0.attendanceDate.prefix(upTo: $0.attendanceDate.firstIndex(of: ":")!) == targetNewDate }
            
        return attendance?.attendanceStatus
    }
    
    private func attendanceColor(forHour hour: Int) -> Color {
        let hourString = String(format: "%02d", hour)
        let targetDate = dateFormatter.string(from: date) + "T" + hourString
        let targetNewDate = targetDate.prefix(upTo: targetDate.firstIndex(of: "T")!) + "T" + hourString

        let attendance = attendanceDetails.first { $0.attendanceDate.prefix(upTo: $0.attendanceDate.firstIndex(of: ":")!) == targetNewDate }
        
        return attendance != nil ? color(for: attendance!.attendanceStatus) : .clear
    }
    
    private func color(for status: AttendanceStatus?) -> Color {
        guard let status = status else { return .clear }
        switch status {
        case .PRESENT:
            return .green.opacity(0.7)
        case .ABSENT:
            return .red.opacity(0.7)
        case .LATE:
            return .yellow.opacity(0.7)
        }
    }
}
