//
//  SendTokenHelp.swift
//  kidomo
//
//  Created by qinqubo on 2024/8/19.
//

import Foundation

class SendTokenHelper {
    
    static func updateFirebaseToken(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Your server's API endpoint
        guard let url = URL(string: "https://saas-test.opsfast.com/api/blade-common/firebase-token/update-token") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // The header
        let viewModel = MessageViewModel()
        if let messageData = viewModel.retrieveMessage() {
            request.allHTTPHeaderFields = [
                "Blade-Auth": messageData.BladeAuth,
                "Authorization": messageData.Authorization
            ]
        }
        
        // The payload
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = ["token": token, "platform": "ios"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
        
        // For debugging:
        if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
            print("Request Body (JSON): \(jsonString)")
        }
        print("header = \(request.allHTTPHeaderFields!)")
        
        // Create the task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                completion(.success(str ?? ""))
            } else {
                completion(.failure(NetworkError.unknownError))
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // Define some custom errors
    enum NetworkError: Error {
        case invalidURL
        case unknownError
    }
}
