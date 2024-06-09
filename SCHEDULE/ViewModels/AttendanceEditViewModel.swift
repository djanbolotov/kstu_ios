//
//  AttendanceEditViewModel.swift
//  SCHEDULE
//
//  Created by Djanbolotov Askabek on 1/6/24.
//

import Foundation

class AttendanceEditViewModel: ObservableObject {
    @Published var attendances: [AttendanceForCreateOrEditDTO]

    init(attendances: [AttendanceForCreateOrEditDTO]) {
        self.attendances = attendances
    }
    
    func saveAttendances(statementId: Int, date: String) {
        let url = URL(string: "http://localhost:8080/api/attendance/save")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let attendanceRequest = AttendanceRequest(statementId: statementId, date: date, attendances: attendances)
        
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
                    do {
                        let responseString = String(data: data, encoding: .utf8)
                        print("Response: \(responseString ?? "No response")")
                    } catch {
                        print("Error parsing response data: \(error.localizedDescription)")
                    }
                }
            }
            task.resume()
        } catch {
            print("Error encoding request body: \(error.localizedDescription)")
        }
    }
}
