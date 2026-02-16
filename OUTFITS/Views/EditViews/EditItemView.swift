import SwiftUI
import PhotosUI

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
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var inputImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isProcessingImage = false
    @State private var showingPhotosPicker = false
    
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
        NavigationStack {
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
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sauvegarder") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || brand.isEmpty)
                }
            }
        }
        .confirmationDialog("Choisir une photo", isPresented: $showingActionSheet) {
            Button("Prendre une photo") {
                showingCamera = true
            }
            Button("Choisir dans la bibliothèque") {
                showingPhotosPicker = true
            }
            Button("Annuler", role: .cancel) { }
        }
        .photosPicker(isPresented: $showingPhotosPicker, selection: $selectedPhoto, matching: .images)
        .sheet(isPresented: $showingCamera) {
            ImagePicker(image: $inputImage, sourceType: .camera)
        }
        .onChange(of: selectedPhoto) {
            Task {
                if let item = selectedPhoto,
                   let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await processImage(uiImage)
                }
            }
        }
        .onChange(of: inputImage) {
            if let image = inputImage {
                Task {
                    await processImage(image)
                }
            }
        }
    }
    
    private func processImage(_ image: UIImage) async {
        isProcessingImage = true
        if let processedImage = await ImageProcessor.removeBackground(from: image),
           let data = processedImage.pngData() {
            await MainActor.run {
                self.imageData = data
                self.isProcessingImage = false
            }
        } else if let data = image.jpegData(compressionQuality: 0.8) {
            await MainActor.run {
                self.imageData = data
                self.isProcessingImage = false
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
        
        updatedItem.id = item.id

        wardrobeManager.updateItem(updatedItem)
        dismiss()
    }
}

#Preview {
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
