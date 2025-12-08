//
//  SpotifyToAppleView.swift
//  listBridge
//
//  Created by Anıl Aygün on 4.12.2025.
//

import SwiftUI

struct SpotifyToAppleView: View {
    var body: some View {
        SelectPlaylistScreen(
            sourceName: "Spotify",
            sourceIcon: "spotify",
            sourceThemeColor: .green,
            targetName: "Apple Music",
            targetIcon: "applelogo",
            targetButtonColor: Color(red: 0.98, green: 0.17, blue: 0.22)
        )
    }
}

#Preview {
    SpotifyToAppleView()
}
