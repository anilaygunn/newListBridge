//
//  KeychainService.swift
//  listBridge
//
//  Created by Anıl Aygün on 26.11.2025.
//

import Foundation
import Security
import LocalAuthentication

actor KeychainService {
    
    static let shared = KeychainService()
    
    private init() {}
    
    func save(_ data: Data, service: String, account: String){
        let query = [
                    kSecValueData: data,
                    kSecClass: kSecClassGenericPassword,
                    kSecAttrAccount: account,
                    kSecAttrService: service
                ] as CFDictionary
        
        SecItemDelete(query as CFDictionary)
        
        SecItemAdd(query, nil)
    }
    
    func read(service:String ,account: String) -> Data? {
        let query = [
                    kSecAttrService: service,
                    kSecAttrAccount: account,
                    kSecClass: kSecClassGenericPassword,
                    kSecReturnData: true
                ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        return result as? Data
    }
    
    func delete(service: String, account: String) {
            let query = [
                kSecAttrService: service,
                kSecAttrAccount: account,
                kSecClass: kSecClassGenericPassword,
            ] as CFDictionary
            
            SecItemDelete(query)
    }
}

extension KeychainService{
    
    func saveString(_ value : String, service: String, account:String){
        if let data = value.data(using: .utf8) {
            save(data, service: service, account: account)
        }
    }
    func readString(service:String ,account: String) -> String? {
        if let data = read(service: service, account: account) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
