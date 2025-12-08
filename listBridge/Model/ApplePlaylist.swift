
import Foundation
import SwiftData

@Model
class ApplePlaylist: Identifiable {
    @Attribute(.unique) var id: String
    var name: String
    var href: String
    var isPublic: Bool
    var lastSyncedDate: Date?
    var imageUrl: String?
    var trackCount: Int
    
    
    init(id: String, name: String, href: String, isPublic: Bool, imageUrl: String? = nil, trackCount: Int = 0) {
        self.id = id
        self.name = name
        self.href = href
        self.isPublic = isPublic
        self.imageUrl = imageUrl
        self.trackCount = trackCount
        self.lastSyncedDate = Date()
    }
}
