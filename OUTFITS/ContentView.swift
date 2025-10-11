import SwiftUI

struct ContentView: View {
    @StateObject private var wardrobeManager = WardrobeManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Accueil")
                }
                .tag(0)
            
            WardrobeView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "tshirt")
                    Text("Dressing")
                }
                .tag(1)
            
            OutfitsView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "figure.dress.line.vertical.figure")
                    Text("Outfits")
                }
                .tag(2)
            
            FavoritesView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favoris")
                }
                .tag(3)
        }
        .accentColor(.purple)
    }   
}

#Preview {
    ContentView()
}
