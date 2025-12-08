import SwiftUI

struct MainView: View {
    
    @State private var selectedOption: Int = 1
    @State private var shouldNavigate: Bool = false
    
    var body: some View {
        
        NavigationStack{
            
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Circle().fill(Color.green.opacity(0.1)).frame(width: 200, height: 200).blur(radius: 50)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Circle().fill(Color.red.opacity(0.1)).frame(width: 200, height: 200).blur(radius: 50)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Transfer Playlists")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Select the direction of your transfer")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    
                    VStack(spacing: 20) {
                        
                        
                        TransferOptionCard(
                            sourceIcon: "spotify_logo",
                            sourceName: "Spotify",
                            sourceColor: .green,
                            sourceIsSystem: false,
                            
                            destIcon: "applelogo",
                            destName: "Apple Music",
                            destColor: .red,
                            destIsSystem: true,
                            
                            isSelected: selectedOption == 0
                        )
                        .onTapGesture { selectedOption = 0 }
                        
                        
                        TransferOptionCard(
                            sourceIcon: "applelogo",
                            sourceName: "Apple Music",
                            sourceColor: .red,
                            sourceIsSystem: true,
                            
                            destIcon: "spotify_logo",
                            destName: "Spotify",
                            destColor: .green,
                            destIsSystem: false,
                            
                            isSelected: selectedOption == 1
                        )
                        .onTapGesture { selectedOption = 1 }
                    }
                    
                    Spacer()
                    
                    
                    Button(action: {
                        print("Continue tapped")
                        shouldNavigate = true
                    }) {
                        HStack {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                            Image(systemName: "arrow.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: selectedOption == 0
                                                   ? [Color(red: 0.11, green: 0.73, blue: 0.33), Color(red: 0.1, green: 0.6, blue: 0.3)]
                                                   : [Color(red: 0.98, green: 0.17, blue: 0.22), Color(red: 0.8, green: 0.1, blue: 0.15)]
                                                  ),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(
                            color: selectedOption == 0 ? Color.green.opacity(0.5) :Color.red.opacity(0.5),
                            radius: 15, x: 0, y: 5
                        )
                        .animation(.easeInOut, value: selectedOption)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                if selectedOption == 0 {
                    SpotifyToAppleView()
                        .navigationBarBackButtonHidden(true)
                } else {
                    AppleToSpotifyView()
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct TransferOptionCard: View {
    var sourceIcon: String
    var sourceName: String
    var sourceColor: Color
    var sourceIsSystem: Bool = true
    
    var destIcon: String
    var destName: String
    var destColor: Color
    var destIsSystem: Bool = true
    
    var isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
            
                ServiceIconView(icon: sourceIcon, color: sourceColor, isSystemImage: sourceIsSystem)
            
                Text(sourceName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.leading, 8)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .bold))
                
                Spacer()
                
                Text(destName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.trailing, 8)
                
                
                ServiceIconView(icon: destIcon, color: destColor, isSystemImage: destIsSystem)
            }
            .padding(20)
            .background(Color(red: 0.08, green: 0.08, blue: 0.08))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.gray.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
                    .padding(6)
                    .background(Color.white)
                    .clipShape(Circle())
                    .offset(x: 10, y: -10)
            }
        }
        .padding(.horizontal, 10)
        .scaleEffect(isSelected ? 1.0 : 0.98)
        .animation(.spring(), value: isSelected)
    }
}
// MARK: - Helper View for Icons
struct ServiceIconView: View {
    var icon: String
    var color: Color
    var isSystemImage: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.12))
                .frame(width: 44, height: 44)
            
            if isSystemImage {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            } else {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(color)
                    
            }
        }
    }
}

#Preview {
    MainView()
}
