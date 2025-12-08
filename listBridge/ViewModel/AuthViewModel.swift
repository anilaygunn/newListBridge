
import Foundation
import Observation
import AuthenticationServices
import MusicKit
import SwiftUI

@Observable
@MainActor
class AuthViewModel: NSObject {
    
    
    private let authService: AuthServiceProtocol
    
    var isSpotifyLoggedIn: Bool = false
    var isAppleloggedIn: Bool = false
    
    var webAuthSession: ASWebAuthenticationSession?
    
    var canFullyLogin: Bool {
        isAppleloggedIn && isSpotifyLoggedIn
    }
    
    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
        super.init()
    }
    
    // MARK: - Login Status
    func checkLoginStatus() async {
        let spotifyToken = await SpotifyTokenManager.shared.getAccessToken()
        self.isSpotifyLoggedIn = (spotifyToken != nil)
        
        let musicStatus = MusicAuthorization.currentStatus
        let appleUserToken = await AppleTokenManager.shared.getUserToken()
        
        self.isAppleloggedIn = (musicStatus == .authorized && appleUserToken != nil)
    }
    
    // MARK: - Spotify Login
    func logInWithSpotify() async {
        do {
            let authURL = try await authService.getSpotifyLoginURL()
            let callbackScheme = "listBridge"
            
            self.webAuthSession = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: callbackScheme
            ) { [weak self] (callbackURL, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Auth Session Error: \(error.localizedDescription)")
                    return
                }
                
                guard let callbackURL = callbackURL else { return }
                
                Task {
                    await self.handleSpotifyCallback(url: callbackURL)
                }
            }
            
            self.webAuthSession?.presentationContextProvider = self
            self.webAuthSession?.prefersEphemeralWebBrowserSession = false
            self.webAuthSession?.start()
            
        } catch {
            print("Spotify login error: \(error)")
        }
    }
    
    private func handleSpotifyCallback(url: URL) async {
        let queryItems = URLComponents(string: url.absoluteString)?.queryItems
        let code = queryItems?.filter({ $0.name == "code" }).first?.value
        let state = queryItems?.filter({ $0.name == "state" }).first?.value
        
        guard let code = code, let state = state else { return }
        
        do {
            if let tokenData = try await authService.exchangeCodeForToken(code: code, state: state) {
                await SpotifyTokenManager.shared.saveTokens(
                    accessToken: tokenData.accessToken!,
                    refreshToken: tokenData.refreshToken!
                )
                self.isSpotifyLoggedIn = true
            }
        } catch {
            print("Token exchange failed: \(error)")
        }
    }
    
    // MARK: - Apple Music Login
    func requestAppleMusicAccess() async {
        
        let status = await MusicAuthorization.request()
        if status == .authorized {
            
            do{
                guard let devToken = try await authService.getAppleDeveloperTokenFromServer() else {
                    print("Could not retrieve Apple Music User Token (returned nil)")
                    return
                }
                guard let userToken = try await authService.getAppleMusicUserToken(devToken: devToken) else {
                    print("Could not retrieve Apple Music User Token (returned nil)")
                    return
                }
                
                print("IAM WRITING TO KEYCHAIN")
                await AppleTokenManager.shared.saveDevToken(devToken: devToken)
                await AppleTokenManager.shared.saveUserToken(userToken: userToken)
                print("devtoken: \(devToken)")
                print("usertoken: \(userToken)")
                self.isAppleloggedIn = true
                
            } catch {
                print("Apple Music Access Error: \(error)")
            }
        }
    }
}

extension AuthViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
