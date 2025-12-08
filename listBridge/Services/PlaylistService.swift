import Foundation
import MusicKit
import SwiftUI

protocol PlaylistServiceProtocol {
    func getSpotifyPlaylists() async throws -> [SpotifyPlaylistDTO]
    func getAppleMusicPlaylists() async throws -> [ApplePlaylistDTO]?
}

class PlaylistService: PlaylistServiceProtocol {
    
    private let baseURL = "http://localhost:3000/api/playlists"
    
    func getSpotifyPlaylists() async throws -> [SpotifyPlaylistDTO] {
        let getSpotifyListsURL = "\(self.baseURL)/spotify/me"
        
        guard let url = URL(string: getSpotifyListsURL) else {
            throw PlaylistError.noURLFound
        }
        
        guard let token = await SpotifyTokenManager.shared.getAccessToken() else {
            throw PlaylistError.noTokenFound
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let response: SpotifyPlaylistResponse = try await NetworkManager.shared.request(request)
        return response.items
    }
    
    func getAppleMusicPlaylists() async throws -> [ApplePlaylistDTO]? {
        let status = await MusicAuthorization.request()
        
        guard status == .authorized else {
            throw PlaylistError.musicKitNotAuthorized
        }
        
        guard let userToken = await AppleTokenManager.shared.getUserToken() else{
            throw PlaylistError.noTokenFound
        }
        guard let devToken = await AppleTokenManager.shared.getDevToken() else{
            throw PlaylistError.noTokenFound
        }
        
        let getAppleListsURL = "\(self.baseURL)/apple-music/me"
        
        guard let url = URL(string: getAppleListsURL) else {
            throw PlaylistError.noURLFound
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("\(userToken)", forHTTPHeaderField: "Music-User-Token")
        request.setValue("\(devToken)", forHTTPHeaderField: "Authorization")
        
        do{
           let (data,response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
                throw PlaylistError.noResponse
            }
            
            let decoder = JSONDecoder()
            let playlists: [ApplePlaylistDTO] = try decoder.decode([ApplePlaylistDTO].self, from: data)
            
            return playlists
            
        }catch{
            return nil
        }
        
    }
}
enum PlaylistError: Error{
    case noURLFound
    case noTokenFound
    case musicKitNotAuthorized
    case noResponse
}
