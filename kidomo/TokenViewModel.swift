//
//  TokenViewModel.swift
//  kidomo
//
//  Created by qinqubo on 2024/8/19.
//

import Foundation

class TokenViewModel: Codable {
    var token: String? {
        didSet {
            saveTokenToStorage()
        }
    }

    private let tokenKey = "firebaseFCMToken"
    
    enum CodingKeys: String, CodingKey {
        case token
    }
    
    init() {
        loadTokenFromStorage()
    }
    
    private func saveTokenToStorage() {
        if let token = token {
            if let encodedData = try? JSONEncoder().encode(self) {
                UserDefaults.standard.set(encodedData, forKey: tokenKey)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: tokenKey)
        }
    }
    
    private func loadTokenFromStorage() {
        if let savedData = UserDefaults.standard.data(forKey: tokenKey) {
            if let decodedTokenViewModel = try? JSONDecoder().decode(TokenViewModel.self, from: savedData) {
                self.token = decodedTokenViewModel.token
            }
        }
    }
    
    func updateToken(_ newToken: String) {
        token = newToken
    }

    func clearToken() {
        token = nil
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
    }
}
