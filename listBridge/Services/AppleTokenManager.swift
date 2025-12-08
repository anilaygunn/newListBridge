//
//  AppleTokenManager.swift
//  listBridge
//
//  Created by Anıl Aygün on 6.12.2025.
//

import Foundation

class AppleTokenManager{
    
    static let shared = AppleTokenManager()
    
    private init(){}
    
    func saveUserToken(userToken: String) async  {
        await KeychainService.shared.saveString(userToken,
                                    service: AppleKeys.service,
                                    account:AppleKeys.userTokenAccount)
        
    }
    func saveDevToken(devToken: String) async  {
        await KeychainService.shared.saveString(devToken,
                                                service: AppleKeys.service,
                                                account: AppleKeys.devTokenAccount)
    }
    
    func getUserToken() async -> String? {
        return await KeychainService.shared.readString(service: AppleKeys.service,
                                                       account: AppleKeys.userTokenAccount)
    }
    func getDevToken() async -> String? {
        return await KeychainService.shared.readString(service: AppleKeys.service,
                                                       account: AppleKeys.devTokenAccount)
    }
    
    func deleteAppleTokens() async {
        await KeychainService.shared.delete(service: AppleKeys.service,
                                            account: AppleKeys.userTokenAccount)
        await KeychainService.shared.delete(service: AppleKeys.service,
                                            account: AppleKeys.devTokenAccount)
        
    }
}
