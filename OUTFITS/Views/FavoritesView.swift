import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Favoris", selection: $selectedTab) {
                    Text("Outfits").tag(0)
                    Text("Articles").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    favoriteOutfitsView
                        .tag(0)
                    
                    favoriteItemsView
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Favoris")
        }
    }
    
    private var favoriteOutfitsView: some View {
        Group {
            if wardrobeManager.favoriteOutfits.isEmpty {
                emptyFavoritesView
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(wardrobeManager.favoriteOutfits) { outfit in
                            OutfitCard(outfit: outfit)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    private var favoriteItemsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tshirt")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Articles favoris")
                .font(.title2)

            
            Text("Cette fonctionnalité sera disponible prochainement")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Aucun favori")
                .font(.title2)

            
            Text("Marquez vos outfits préférés avec un cœur")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FavoritesView_Previews: PreviewProvider { static var previews: some View {
    FavoritesView()
        .environmentObject(WardrobeManager())
}


}