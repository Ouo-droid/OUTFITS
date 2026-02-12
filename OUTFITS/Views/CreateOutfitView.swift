import SwiftUI

struct CreateOutfitView: View {
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var outfitName = ""
    @State private var selectedItems: Set<Item> = []
    @State private var season = Season.all
    @State private var occasion = Occasion.casual
    @State private var rating = 3
    @State private var notes = ""
    @State private var isFavorite = false
    @State private var selectedCategory: ItemCategory?
    
    var availableItems: [Item] {
        if let category = selectedCategory {
            return wardrobeManager.getItemsByCategory(category)
        }
        return wardrobeManager.items
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section("Informations de l'outfit") {
                        TextField("Nom de l'outfit", text: $outfitName)
                        
                        Picker("Saison", selection: $season) {
                            ForEach(Season.allCases, id: \.self) { season in
                                HStack {
                                    Circle()
                                        .fill(season.color)
                                        .frame(width: 12, height: 12)
                                    Text(season.rawValue)
                                }
                                .tag(season)
                            }
                        }
                        
                        Picker("Occasion", selection: $occasion) {
                            ForEach(Occasion.allCases, id: \.self) { occasion in
                                HStack {
                                    Image(systemName: occasion.icon)
                                        .foregroundColor(occasion.color)
                                    Text(occasion.rawValue)
                                }
                                .tag(occasion)
                            }
                        }
                        
                        HStack {
                            Text("Note")
                            Spacer()
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .onTapGesture {
                                            rating = star
                                        }
                                }
                            }
                        }
                        
                        Toggle("Favori", isOn: $isFavorite)
                    }
                    
                    Section("Notes") {
                        TextField("Notes (optionnel)", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
                .frame(height: 300)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Articles sélectionnés")
                            .font(.headline)
                            // .fontWeight(.semibold) iOS 16+
                        
                        Spacer()
                        
                        Text("\(selectedItems.count) articles")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    if selectedItems.isEmpty {
                        Text("Aucun article sélectionné")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(selectedItems), id: \.id) { item in
                                    SelectedItemCard(item: item) {
                                        selectedItems.remove(item)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choisir des articles")
                        .font(.headline)
                        // .fontWeight(.semibold) iOS 16+
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button("Toutes") {
                                selectedCategory = nil
                            }
                            .buttonStyle(CategoryFilterButton(isSelected: selectedCategory == nil))
                            
                            ForEach(ItemCategory.allCases, id: \.self) { category in
                                Button(category.rawValue) {
                                    selectedCategory = category
                                }
                                .buttonStyle(CategoryFilterButton(isSelected: selectedCategory == category))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(availableItems) { item in
                            ItemSelectionCard(
                                item: item,
                                isSelected: selectedItems.contains(item)
                            ) {
                                if selectedItems.contains(item) {
                                    selectedItems.remove(item)
                                } else {
                                    selectedItems.insert(item)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Nouvel outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Annuler")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        createOutfit()
                    }) {
                        Text("Créer")
                    }
                    .disabled(outfitName.isEmpty || selectedItems.isEmpty)
                }
            }
        }
    }
    
    private func createOutfit() {
        let newOutfit = Outfit(
            name: outfitName,
            items: Array(selectedItems),
            season: season,
            occasion: occasion,
            rating: rating,
            notes: notes,
            isFavorite: isFavorite
        )
        
        wardrobeManager.addOutfit(newOutfit)
        dismiss()
    }
}

struct SelectedItemCard: View {
    let item: Item
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(8)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: item.category.icon)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(item.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(width: 60)
        }
        .overlay(
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .offset(x: 25, y: -25),
            alignment: .topTrailing
        )
    }
}

struct ItemSelectionCard: View {
    let item: Item
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 8) {
                if let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: item.category.icon)
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(item.name)
                    .font(.caption)
                    .lineLimit(1)
                    .frame(width: 80)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 2)
            )
            .overlay(
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .purple : .secondary)
                    .background(Color.white)
                    .clipShape(Circle())
                    .offset(x: 30, y: -30),
                alignment: .topTrailing
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategoryFilterButton: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium)) // Replaces .font(.caption).fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.purple : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct CreateOutfitView_Previews: PreviewProvider { static var previews: some View {
    CreateOutfitView()
        .environmentObject(WardrobeManager())
}




}