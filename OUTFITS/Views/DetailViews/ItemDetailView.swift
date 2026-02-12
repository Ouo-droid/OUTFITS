import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let imageData = item.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray5))
                                .frame(height: 200)
                            
                            VStack(spacing: 12) {
                                Image(systemName: item.category.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                
                                Text("Aucune photo")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.name)
                                .font(.title2)

                            
                            Text(item.brand)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 20) {
                            InfoBadge(
                                icon: item.category.icon,
                                title: "Catégorie",
                                value: item.category.rawValue
                            )
                            
                            InfoBadge(
                                icon: "calendar",
                                title: "Saison",
                                value: item.season.rawValue,
                                color: item.season.color
                            )
                        }
                        
                        HStack(spacing: 20) {
                            InfoBadge(
                                icon: "paintpalette",
                                title: "Couleur",
                                value: item.color,
                                color: Color(item.color.lowercased()) ?? .gray
                            )
                            
                            InfoBadge(
                                icon: "ruler",
                                title: "Taille",
                                value: item.size
                            )
                        }
                        
                        InfoBadge(
                            icon: "calendar.badge.plus",
                            title: "Ajouté le",
                            value: item.dateAdded.formatted(date: .abbreviated, time: .omitted)
                        )
                        
                        if !item.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes")
                                    .font(.headline)

                                
                                Text(item.notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
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
            EditItemView(item: item)
                .environmentObject(wardrobeManager)
        }
        .alert("Supprimer l'article", isPresented: $showingDeleteAlert) {
            Button("Supprimer", role: .destructive) {
                wardrobeManager.deleteItem(item)
                dismiss()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Êtes-vous sûr de vouloir supprimer cet article ? Cette action est irréversible.")
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    init(icon: String, title: String, value: String, color: Color = .primary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ItemDetailView_Previews: PreviewProvider { static var previews: some View {
    let sampleItem = Item(
        name: "T-shirt blanc",
        brand: "Zara",
        category: .top,
        color: "Blanc",
        size: "M",
        season: .summer,
        notes: "Très confortable, parfait pour l'été"
    )
    
    return ItemDetailView(item: sampleItem)
        .environmentObject(WardrobeManager())
}




}