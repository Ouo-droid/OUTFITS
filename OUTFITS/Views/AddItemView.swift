import SwiftUI
import PhotosUI

struct AddItemView: View {
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var brand = ""
    @State private var category = ItemCategory.top
    @State private var color = ""
    @State private var size = ""
    @State private var season = Season.all
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingImagePicker = false
    
    private let commonColors = ["Blanc", "Noir", "Rouge", "Bleu", "Vert", "Jaune", "Rose", "Violet", "Orange", "Marron", "Gris", "Beige"]
    private let commonSizes = ["XS", "S", "M", "L", "XL", "XXL", "36", "38", "40", "42", "44", "46", "48"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations générales") {
                    TextField("Nom de l'article", text: $name)
                    TextField("Marque", text: $brand)
                }
                
                Section("Catégorie et style") {
                    Picker("Catégorie", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
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
                }
                
                Section("Détails") {
                    Picker("Couleur", selection: $color) {
                        ForEach(commonColors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(Color(color.lowercased()) ?? .gray)
                                    .frame(width: 16, height: 16)
                                Text(color)
                            }
                            .tag(color)
                        }
                    }
                    
                    Picker("Taille", selection: $size) {
                        ForEach(commonSizes, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                }
                
                Section("Photo") {
                    if let imageData = imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Button("Ajouter une photo") {
                            showingImagePicker = true
                        }
                        .foregroundColor(.purple)
                    }
                }
                
                Section("Notes") {
                    TextField("Notes (optionnel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nouvel article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || brand.isEmpty)
                }
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedPhoto, matching: .images)
        .onChange(of: selectedPhoto) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    private func saveItem() {
        let newItem = Item(
            name: name,
            brand: brand,
            category: category,
            color: color,
            size: size,
            season: season,
            imageData: imageData,
            notes: notes
        )
        
        wardrobeManager.addItem(newItem)
        dismiss()
    }
}

#Preview {
    AddItemView()
        .environmentObject(WardrobeManager())
}


