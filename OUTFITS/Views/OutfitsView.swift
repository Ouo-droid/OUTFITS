import SwiftUI

struct OutfitsView: View {
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @State private var searchText = ""
    @State private var selectedOccasion: Occasion?
    @State private var selectedSeason: Season?
    @State private var showingCreateOutfit = false
    @State private var sortOption: OutfitSortOption = .dateCreated
    
    enum OutfitSortOption: String, CaseIterable {
        case dateCreated = "Date de création"
        case name = "Nom"
        case rating = "Note"
        case lastWorn = "Dernière fois porté"
    }
    
    var filteredOutfits: [Outfit] {
        var outfits = wardrobeManager.outfits
        
        if !searchText.isEmpty {
            outfits = wardrobeManager.searchOutfits(query: searchText)
        }
        
        if let occasion = selectedOccasion {
            outfits = outfits.filter { $0.occasion == occasion }
        }
        
        if let season = selectedSeason {
            outfits = outfits.filter { $0.season == season || $0.season == .all }
        }
        
        switch sortOption {
        case .dateCreated:
            outfits = outfits.sorted { $0.dateCreated > $1.dateCreated }
        case .name:
            outfits = outfits.sorted { $0.name < $1.name }
        case .rating:
            outfits = outfits.sorted { $0.rating > $1.rating }
        case .lastWorn:
            outfits = outfits.sorted { outfit1, outfit2 in
                let date1 = outfit1.lastWorn ?? Date.distantPast
                let date2 = outfit2.lastWorn ?? Date.distantPast
                return date1 > date2
            }
        }
        
        return outfits
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterSection
                
                if filteredOutfits.isEmpty {
                    emptyStateView
                } else {
                    outfitsGrid
                }
            }
            .navigationTitle("Mes Outfits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Créer") {
                        showingCreateOutfit = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateOutfit) {
            CreateOutfitView()
                .environmentObject(wardrobeManager)
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Rechercher un outfit...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Effacer") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.purple)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Menu {
                        Button("Toutes les occasions") {
                            selectedOccasion = nil
                        }
                        
                        ForEach(Occasion.allCases, id: \.self) { occasion in
                            Button(occasion.rawValue) {
                                selectedOccasion = occasion
                            }
                        }
                    } label: {
                        FilterChip(
                            title: selectedOccasion?.rawValue ?? "Occasion",
                            isSelected: selectedOccasion != nil
                        )
                    }
                    
                    Menu {
                        Button("Toutes les saisons") {
                            selectedSeason = nil
                        }
                        
                        ForEach(Season.allCases, id: \.self) { season in
                            Button(season.rawValue) {
                                selectedSeason = season
                            }
                        }
                    } label: {
                        FilterChip(
                            title: selectedSeason?.rawValue ?? "Saison",
                            isSelected: selectedSeason != nil
                        )
                    }
                    
                    Menu {
                        ForEach(OutfitSortOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                sortOption = option
                            }
                        }
                    } label: {
                        FilterChip(
                            title: "Trier",
                            isSelected: false
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.dress.line.vertical.figure")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Aucun outfit trouvé")
                .font(.title2.weight(.semibold))
            
            Text("Créez votre premier outfit !")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Créer un outfit") {
                showingCreateOutfit = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var outfitsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredOutfits) { outfit in
                    OutfitCard(outfit: outfit)
                }
            }
            .padding()
        }
    }
}

struct OutfitsView_Previews: PreviewProvider { static var previews: some View {
    OutfitsView()
        .environmentObject(WardrobeManager())
}



}