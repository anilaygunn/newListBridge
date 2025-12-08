
import Foundation
import Observation

import SwiftData
import SwiftUI
import MusicKit

@Observable
@MainActor
class SelectPlaylistViewModel {
    
    private let playlistService: PlaylistServiceProtocol
    
   
    var searchText: String = ""
    var selectedPlaylistID: String?
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(playlistService: PlaylistServiceProtocol? = nil) {
        self.playlistService = playlistService ?? PlaylistService()
    }
    
    func fetchPlaylists(source: String, modelContext: ModelContext) async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            if source == "Spotify" {
                let spotifyDTOs = try await playlistService.getSpotifyPlaylists()
                
                for dto in spotifyDTOs {
                    let imageUrl = dto.images?.first?.url
                    
                    
                    let id = dto.id
                    let descriptor = FetchDescriptor<SpotifyPlaylist>(predicate: #Predicate { $0.id == id })
                    
                    if let existing = try? modelContext.fetch(descriptor).first {
                        existing.name = dto.name
                        existing.imageUrl = imageUrl
                        existing.trackCount = dto.trackCount
                        
                    } else {
                        let newPlaylist = SpotifyPlaylist(
                            id: dto.id,
                            name: dto.name,
                            imageUrl: imageUrl,
                            trackCount: dto.trackCount
                        )
                        modelContext.insert(newPlaylist)
                    }
                }
                
            } else if source == "Apple Music" {
                print("Fetching Apple Music playlists..."
                )
                if let applePlaylists = try await playlistService.getAppleMusicPlaylists() {
                    print("Fetched \(applePlaylists.count) Apple Music playlists.")
                    for dto in applePlaylists {
                        let id = dto.id

                        let tempModel = dto.toPersistentModel()
                        print("Processing playlist: \(tempModel.name)")
                        
                        let descriptor = FetchDescriptor<ApplePlaylist>(predicate: #Predicate { $0.id == id })
                        
                        if let existing = try? modelContext.fetch(descriptor).first {
                            existing.name = dto.attributes.name
                            existing.imageUrl = tempModel.imageUrl
                            existing.trackCount = tempModel.trackCount
                        } else {
                            modelContext.insert(tempModel)
                        }
                    }
                } else {
                    print("Apple Music playlists returned nil.")
                }
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print("Error fetching playlists: \(error)")
        }
        
        self.isLoading = false
    }
    
    func selectPlaylist(id: String) {
        if self.selectedPlaylistID == id {
            self.selectedPlaylistID = nil
        } else {
            self.selectedPlaylistID = id
        }
    }
}
