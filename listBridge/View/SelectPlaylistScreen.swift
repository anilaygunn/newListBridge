//
//  SelectPlaylistScreen.swift
//  listBridge
//
//  Created by Anıl Aygün on 4.12.2025.
//

import SwiftUI
import SwiftData


struct SelectPlaylistScreen: View {
    var sourceName: String
    var sourceIcon: String
    var sourceThemeColor: Color
    
    var targetName: String
    var targetIcon: String
    var targetButtonColor: Color
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SelectPlaylistViewModel()
    
    @Query(sort: \SpotifyPlaylist.name) private var spotifyPlaylists: [SpotifyPlaylist]
    @Query(sort: \ApplePlaylist.name) private var applePlaylists: [ApplePlaylist]
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                headerView
                importUrlSection
                librarySection
                actionButton
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await viewModel.fetchPlaylists(source: sourceName, modelContext: modelContext)
            }
        }
    }
    
    
    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Select Playlist")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(sourceThemeColor)
                        .frame(width: 8, height: 8)
                    Text("\(sourceName) Source")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 10)
            
            Spacer()
        }
        .padding(.top, 10)
    }
    
    var importUrlSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("IMPORT FROM URL")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding(.leading, 4)
            
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.gray)
                Text("Paste \(sourceName) playlist link...")
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
            .frame(height: 50)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
        }
    }
    
    var librarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("YOUR LIBRARY")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
                
                Text("\(currentListCount) playlists")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Filter playlists...", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .accentColor(sourceThemeColor)
            }
            .padding()
            .frame(height: 45)
            .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            .cornerRadius(10)
            
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack(spacing: 12) {
                        if sourceName == "Spotify" {
                            ForEach(filteredSpotifyPlaylists) { playlist in
                                PlaylistRowItem(
                                    name: playlist.name,
                                    imageUrl: playlist.imageUrl,
                                    trackCount: playlist.trackCount,
                                    sourceIcon: sourceIcon,
                                    sourceColor: sourceThemeColor,
                                    isSelected: viewModel.selectedPlaylistID == playlist.id
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        viewModel.selectPlaylist(id: playlist.id)
                                    }
                                }
                            }
                        } else if sourceName == "Apple Music" {
                            ForEach(filteredApplePlaylists) { playlist in
                                PlaylistRowItem(
                                    name: playlist.name,
                                    imageUrl: playlist.imageUrl,
                                    trackCount: playlist.trackCount,
                                    sourceIcon: sourceIcon,
                                    sourceColor: sourceThemeColor,
                                    isSelected: viewModel.selectedPlaylistID == playlist.id
                                )
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        viewModel.selectPlaylist(id: playlist.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 5)
                }
            }
        }
    }
    
    var currentListCount: Int {
        if sourceName == "Spotify" {
            return filteredSpotifyPlaylists.count
        } else {
            return filteredApplePlaylists.count
        }
    }
    
    var filteredSpotifyPlaylists: [SpotifyPlaylist] {
        if viewModel.searchText.isEmpty {
            return spotifyPlaylists
        }
        return spotifyPlaylists.filter { $0.name.localizedCaseInsensitiveContains(viewModel.searchText) }
    }
    
    var filteredApplePlaylists: [ApplePlaylist] {
        if viewModel.searchText.isEmpty {
            return applePlaylists
        }
        return applePlaylists.filter { $0.name.localizedCaseInsensitiveContains(viewModel.searchText) }
    }
    
    var actionButton: some View {
        Button(action: {
            print("Transferring to \(targetName)")
        }) {
            HStack {
                Text("Transfer to \(targetName)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                renderIcon(name: targetIcon, color: .white, size: 20)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(targetButtonColor)
            .cornerRadius(30)
            .shadow(color: targetButtonColor.opacity(0.4), radius: 10, y: 5)
            .opacity(viewModel.selectedPlaylistID == nil ? 0.5 : 1.0)
        }
        .disabled(viewModel.selectedPlaylistID == nil)
    }
    
    @ViewBuilder
    func renderIcon(name: String, color: Color, size: CGFloat) -> some View {
        
        if name == "spotify" {
            Image("spotify_logo")
            
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(color)
        } else {
            Image(systemName: name)
                .font(.system(size: size))
                .foregroundColor(color)
        }
    }
}


struct PlaylistRowItem: View {
    let name: String
    let imageUrl: String?
    let trackCount: Int
    let sourceIcon: String
    let sourceColor: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack(alignment: .bottomTrailing) {
                
                if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .cornerRadius(8)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 56, height: 56)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "music.note.list")
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                } else {
                    Rectangle()
                    .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .frame(width: 56, height: 56)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "music.note.list")
                            .foregroundColor(.white.opacity(0.7))
                    )
                }
                
                
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 18, height: 18)
                    
                    
                    if sourceIcon == "spotify" {
                        
                        Image("spotify_logo")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 10, height: 10)
                            .foregroundColor(sourceColor)
                    } else {
                        Image(systemName: sourceIcon)
                            .font(.system(size: 10))
                            .foregroundColor(sourceColor)
                    }
                }
                .offset(x: 4, y: 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? sourceColor : .white)
                
                Text("\(trackCount) tracks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(sourceColor)
            } else {
                Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? sourceColor.opacity(0.1) : Color(red: 0.08, green: 0.08, blue: 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? sourceColor : Color.clear, lineWidth: 1.5)
        )
    }
}

