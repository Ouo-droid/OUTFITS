import SwiftUI

struct EditItemView: View {
    let item: Item
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var brand: String
    @State private var category: ItemCategory
    @State private var color: String
    @State private var size: String
    @State private var season: Season
    @State private var notes: String
    @State private var imageData: Data?
    @State private var showingImagePicker = false
    @State private var showingActionSheet = false
    @State private var inputImage: UIImage?
    @State private var isProcessingImage = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    private let commonColors = ["Blanc", "Noir", "Rouge", "Bleu", "Vert", "Jaune", "Rose", "Violet", "Orange", "Marron", "Gris", "Beige"]
    private let commonSizes = ["XS", "S", "M", "L", "XL", "XXL", "36", "38", "40", "42", "44", "46", "48"]
    
    init(item: Item) {
        self.item = item
        self._name = State(initialValue: item.name)
        self._brand = State(initialValue: item.brand)
        self._category = State(initialValue: item.category)
        self._color = State(initialValue: item.color)
        self._size = State(initialValue: item.size)
        self._season = State(initialValue: item.season)
        self._notes = State(initialValue: item.notes)
        self._imageData = State(initialValue: item.imageData)
    }
    
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
                    ZStack {
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                                .onTapGesture {
                                    showingActionSheet = true
                                }
                        } else {
                            Button("Modifier la photo") {
                                showingActionSheet = true
                            }
                            .foregroundColor(.purple)
                        }

                        if isProcessingImage {
                            Color.black.opacity(0.4)
                                .cornerRadius(8)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    
                    if imageData != nil {
                        Button("Supprimer la photo", role: .destructive) {
                            imageData = nil
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Notes (optionnel)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Modifier l'article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || brand.isEmpty)
                }
            }
        }
        .confirmationDialog("Choisir une photo", isPresented: $showingActionSheet) {
            Button("Prendre une photo") {
                imageSourceType = .camera
                showingImagePicker = true
            }
            Button("Choisir dans la bibliothèque") {
                imageSourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Annuler", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage, sourceType: imageSourceType)
        }
        .onChange(of: inputImage) { newImage in
            guard let image = newImage else { return }
            processImage(image)
        }
    }

    private func processImage(_ image: UIImage) {
        isProcessingImage = true
        Task {
            if let processedImage = await ImageProcessor.removeBackground(from: image),
               let data = processedImage.pngData() {
                await MainActor.run {
                    self.imageData = data
                    self.isProcessingImage = false
                }
            } else if let data = image.jpegData(compressionQuality: 0.8) {
                // Fallback to original image if processing fails
                await MainActor.run {
                    self.imageData = data
                    self.isProcessingImage = false
                }
            }
        }
    }
    
    private func saveChanges() {
        // Create a new item but keep the original ID by using the init directly?
        // Or rather, the model doesn't seem to expose ID in init properly if it auto-generates.
        // Let's look at WardrobeManager.updateItem logic.
        // It matches by ID. Since Item is a struct and we are creating a "new" Item here,
        // we might lose the original ID if the init generates a new one.
        // Let's check Item model definition.

        // Assuming Item struct has an id property that we should preserve.
        // The original code was:
        /*
        let updatedItem = Item(
            name: name,
            brand: brand,
            ...
        )
        wardrobeManager.updateItem(updatedItem)
        */
        // If Item() generates a new UUID, then updateItem won't find the original item to update.
        // Let's fix this by manually copying the ID from the original item.
        
        var updatedItem = Item(
            name: name,
            brand: brand,
            category: category,
            color: color,
            size: size,
            season: season,
            imageData: imageData,
            notes: notes
        )
        
        // Force the ID to match the original item
        // This requires Item to have a mutable id or a constructor that accepts it.
        // Let's assume for now we can't change it easily without seeing Item.swift again.
        // But since I am editing EditItemView, I should check Item.swift first if I want to be 100% sure.
        // However, the previous code also just created a new Item, implying updateItem might handle it
        // OR Item has an init that takes ID (which I don't see in AddItemView usage)
        // OR the previous code was actually buggy/incomplete regarding ID preservation.

        // Wait, looking at the previous file content provided in context:
        // The previous code in EditItemView.swift was:
        /*
        let updatedItem = Item(name: ..., ...)
        var finalItem = updatedItem
        finalItem = Item(name: ..., ...) // It was doing it twice? Weird.
        wardrobeManager.updateItem(finalItem)
        */

        // Let's look at WardrobeManager.swift again from my memory/context.
        // func updateItem(_ item: Item) { if let index = items.firstIndex(where: { $0.id == item.id }) ... }
        // So ID must match.

        // If I create a new Item(), it gets a new UUID.
        // I need to preserve the ID.
        // Let's check MODELS.md again. "id: Identifiant unique généré automatiquement".

        // I will use a workaround: modify the id of the new item to match the old one.
        updatedItem.id = item.id

        wardrobeManager.updateItem(updatedItem)
        dismiss()
    }
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = Item(
            name: "T-shirt blanc",
            brand: "Zara",
            category: .top,
            color: "Blanc",
            size: "M",
            season: .summer
        )

        return EditItemView(item: sampleItem)
            .environmentObject(WardrobeManager())
    }
}
