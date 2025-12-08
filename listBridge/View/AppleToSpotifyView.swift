//
//  AppleToSpotifyView.swift
//  listBridge
//
//  Created by Anıl Aygün on 4.12.2025.
//

import SwiftUI

struct AppleToSpotifyView: View {
    var body: some View {
        SelectPlaylistScreen(
            sourceName: "Apple Music",
            sourceIcon: "applelogo",
            sourceThemeColor: .red,
            targetName: "Spotify",
            targetIcon: "spotify",
            targetButtonColor: Color(red: 0.11, green: 0.73, blue: 0.33)
        )
    }
}

#Preview {
    AppleToSpotifyView()
}
