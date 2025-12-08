
import Foundation

struct SpotifyPlaylistDTO: Identifiable, Codable {
    let id: String
    let name: String
    let images: [SpotifyImage]?
    let tracks: SpotifyTracksInfo
    
    var imageName: String {
        return "music.note.list"
    }
    
    var trackCount: Int {
        return tracks.total
    }
}

struct SpotifyImage: Codable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyTracksInfo: Codable {
    let href: String
    let total: Int
}

struct SpotifyPlaylistResponse: Codable {
    let items: [SpotifyPlaylistDTO]
    let total: Int
    let limit: Int
    let offset: Int
}
