import SwiftUI

struct OutfitDetailView: View {
    let outfit: Outfit
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var showingMarkAsWornAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    outfitHeader
                    
                    outfitItems
                    
                    outfitDetails
                    
                    outfitActions
                }
                .padding()
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Modifier") {
                            showingEditView = true
                        }
                        
                        Button("Marquer comme porté") {
                            showingMarkAsWornAlert = true
                        }
                        
                        Button("Supprimer", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            EditOutfitView(outfit: outfit)
                .environmentObject(wardrobeManager)
        }
        .alert("Marquer comme porté", isPresented: $showingMarkAsWornAlert) {
            Button("Confirmer") {
                wardrobeManager.markOutfitAsWorn(outfit)
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Cet outfit sera marqué comme porté aujourd'hui.")
        }
        .alert("Supprimer l'outfit", isPresented: $showingDeleteAlert) {
            Button("Supprimer", role: .destructive) {
                wardrobeManager.deleteOutfit(outfit)
                dismiss()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cet outfit ? Cette action est irréversible.")
        }
    }
    
    private var outfitHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Text(outfit.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if outfit.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.pink)
                        .font(.title3)
                }
            }
            
            HStack(spacing: 12) {
                OccasionBadge(occasion: outfit.occasion)
                SeasonBadge(season: outfit.season)
            }
            
            HStack(spacing: 4) {
                Text("Note:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= outfit.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var outfitItems: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Articles (\(outfit.totalItems))")
                .font(.headline)
                .fontWeight(.semibold)
            
            if outfit.items.isEmpty {
                Text("Aucun article dans cet outfit")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(outfit.items) { item in
                        OutfitItemCard(item: item)
                    }
                }
            }
        }
    }
    
    private var outfitDetails: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                DetailRow(
                    icon: "calendar.badge.plus",
                    title: "Créé le",
                    value: outfit.dateCreated.formatted(date: .abbreviated, time: .omitted),
                    valueColor: .primary
                )
                
                if let lastWorn = outfit.lastWorn {
                    DetailRow(
                        icon: "calendar.badge.clock",
                        title: "Dernière fois porté",
                        value: lastWorn.formatted(date: .abbreviated, time: .omitted),
                        valueColor: .primary
                    )
                }
                
                DetailRow(
                    icon: "checkmark.circle",
                    title: "Outfit complet",
                    value: outfit.hasCompleteOutfit ? "Oui" : "Non",
                    valueColor: outfit.hasCompleteOutfit ? .green : .orange
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
s
            if !outfit.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(outfit.notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var outfitActions: some View {
        VStack(spacing: 12) {
            Button("Marquer comme porté") {
                showingMarkAsWornAlert = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .frame(maxWidth: .infinity)
        }
    }
}

struct OccasionBadge: View {
    let occasion: Occasion
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: occasion.icon)
                .foregroundColor(occasion.color)
                .font(.caption)
            
            Text(occasion.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(occasion.color.opacity(0.2))
        .cornerRadius(8)
    }
}

struct SeasonBadge: View {
    let season: Season
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(season.color)
                .frame(width: 8, height: 8)
            
            Text(season.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(season.color.opacity(0.2))
        .cornerRadius(8)
    }
}

struct OutfitItemCard: View {
    let item: Item
    
    var body: some View {
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
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let valueColor: Color
    
    init(icon: String, title: String, value: String, valueColor: Color = .primary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

struct EditOutfitView: View {
    let outfit: Outfit
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Modification d'outfit")
                    .font(.title)
                    .padding()
                
                Text("Cette fonctionnalité sera disponible prochainement")
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Modifier l'outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleOutfit = Outfit(
        name: "Look décontracté",
        items: [],
        season: .summer,
        occasion: .casual,
        rating: 4,
        notes: "Parfait pour une sortie en ville"
    )
    
    return OutfitDetailView(outfit: sampleOutfit)
        .environmentObject(WardrobeManager())
}
