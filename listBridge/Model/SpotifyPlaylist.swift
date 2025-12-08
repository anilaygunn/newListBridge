
import Foundation
import SwiftData

@Model
class SpotifyPlaylist: Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    var imageUrl: String?
    var trackCount: Int
    var externalUrl: String?
    
    init(id: String, name: String, imageUrl: String? = nil, trackCount: Int, externalUrl: String? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.trackCount = trackCount
        self.externalUrl = externalUrl
    }
}
