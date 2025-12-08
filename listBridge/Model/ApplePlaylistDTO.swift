//
//  ApplePlaylistDTO.swift
//  listBridge
//
//  Created by Anıl Aygün on 7.12.2025.
//

import Foundation

struct ArtworkDTO: Codable {
    let width: Int
    let height: Int
    let url: String
}

struct ApplePlaylistDTO: Codable{
    let id: String
    let type: String
    let href: String
    let attributes: PlaylistAttributesDTO
    let relationships: PlaylistRelationshipsDTO?
}

struct PlaylistRelationshipsDTO: Codable {
    let tracks: TracksRelationshipDTO?
}

struct TracksRelationshipDTO: Codable {
    let data: [TrackDataDTO]?
    let meta: TracksMetaDTO?
}

struct TrackDataDTO: Codable {
    let id: String
    let type: String
}

struct TracksMetaDTO: Codable {
    let total: Int
}

struct PlayParamsDTO: Codable {
    let id: String
    let kind: String
    let isLibrary : Bool
}
struct PlaylistAttributesDTO: Codable {
    let name: String
    let isPublic: Bool
    let canEdit: Bool
    let hasCatalog: Bool
    let dateAdded: String
    let playParams: PlayParamsDTO
    let artwork: ArtworkDTO?
}
struct PlaylistResponseDTO: Codable {
    let next: String?
    let data: [ApplePlaylistDTO]
    
}

extension ApplePlaylistDTO: Identifiable {
    
    func toPersistentModel() -> ApplePlaylist {
        let artworkURL = self.attributes.artwork?.url
            .replacingOccurrences(of: "{w}", with: "600")
            .replacingOccurrences(of: "{h}", with: "600")
            
        return ApplePlaylist(
            id: self.id,
            name: self.attributes.name,
            href: self.href,
            isPublic: self.attributes.isPublic,
            imageUrl: artworkURL,
            trackCount: self.relationships?.tracks?.meta?.total ?? 0
        )
    }
}
