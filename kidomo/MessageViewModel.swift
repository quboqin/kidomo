//
//  MessageViewModel.swift
//  kidomo
//
//  Created by qinqubo on 2024/6/17.
//

import Foundation

struct MessageData: Codable {
    var BladeAuth: String
    var Authorization: String
    
    // Implementing the initializer is not necessary if default behavior is enough
    // However, if you need custom decoding logic, you can implement this initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.BladeAuth = try container.decode(String.self, forKey: .BladeAuth)
        self.Authorization = try container.decode(String.self, forKey: .Authorization)
    }

    // You can also provide an encoding method if needed (for the Encodable protocol)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(BladeAuth, forKey: .BladeAuth)
        try container.encode(Authorization, forKey: .Authorization)
    }

    // CodingKeys to match the JSON keys
    enum CodingKeys: String, CodingKey {
        case BladeAuth
        case Authorization
    }
}

class MessageViewModel {
    private let messageKey = "KidomoPreferences"

    func saveMessage(_ message: MessageData) {
        if let encodedMessage = try? JSONEncoder().encode(message) {
            UserDefaults.standard.set(encodedMessage, forKey: messageKey)
        }
    }

    func retrieveMessage() -> MessageData? {
        guard let savedMessage = UserDefaults.standard.object(forKey: messageKey) as? Data,
              let loadedMessage = try? JSONDecoder().decode(MessageData.self, from: savedMessage) else {
            return nil
        }
        return loadedMessage
    }
}
