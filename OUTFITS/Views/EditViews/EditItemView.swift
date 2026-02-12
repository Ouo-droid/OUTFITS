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
        
        // Preserve the original ID to update the existing record
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
