import SwiftUI

struct WardrobeView: View {
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @State private var searchText = ""
    @State private var selectedCategory: ItemCategory?
    @State private var selectedSeason: Season?
    @State private var showingAddItem = false
    @State private var sortOption: SortOption = .dateAdded
    
    enum SortOption: String, CaseIterable {
        case dateAdded = "Date d'ajout"
        case name = "Nom"
        case brand = "Marque"
        case category = "Catégorie"
    }
    
    var filteredItems: [Item] {
        var items = wardrobeManager.items
        
        if !searchText.isEmpty {
            items = wardrobeManager.searchItems(query: searchText)
        }
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if let season = selectedSeason {
            items = items.filter { $0.season == season || $0.season == .all }
        }
        
        switch sortOption {
        case .dateAdded:
            items = items.sorted { $0.dateAdded > $1.dateAdded }
        case .name:
            items = items.sorted { $0.name < $1.name }
        case .brand:
            items = items.sorted { $0.brand < $1.brand }
        case .category:
            items = items.sorted { $0.category.rawValue < $1.category.rawValue }
        }
        
        return items
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterSection
                
                if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    itemsGrid
                }
            }
            .navigationTitle("Mon Dressing")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ajouter") {
                        showingAddItem = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView()
                .environmentObject(wardrobeManager)
        }
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Rechercher un article...", text: $searchText)
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
                        Button("Toutes les catégories") {
                            selectedCategory = nil
                        }
                        
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        FilterChip(
                            title: selectedCategory?.rawValue ?? "Catégorie",
                            isSelected: selectedCategory != nil
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
                        ForEach(SortOption.allCases, id: \.self) { option in
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
            Image(systemName: "tshirt")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Aucun article trouvé")
                .font(.title2)

            
            Text("Ajoutez votre premier article à votre dressing")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Ajouter un article") {
                showingAddItem = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var itemsGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    ItemCard(item: item)
                }
            }
            .padding()
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.caption)

            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.purple : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
    }
}

struct WardrobeView_Previews: PreviewProvider { static var previews: some View {
    WardrobeView()
        .environmentObject(WardrobeManager())
}



}