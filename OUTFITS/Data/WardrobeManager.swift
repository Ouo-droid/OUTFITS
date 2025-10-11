import Foundation
import SwiftUI

class WardrobeManager: ObservableObject {
    @Published var items: [Item] = []
    @Published var outfits: [Outfit] = []
    
    private let itemsKey = "SavedItems"
    private let outfitsKey = "SavedOutfits"
    
    init() {
        loadItems()
        loadOutfits()
    }
    
    
    func addItem(_ item: Item) {
        items.append(item)
        saveItems()
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }
    
    func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        for outfit in outfits {
            if outfit.items.contains(where: { $0.id == item.id }) {
                deleteOutfit(outfit)
            }
        }
        saveItems()
    }
    
    func getItemsByCategory(_ category: ItemCategory) -> [Item] {
        return items.filter { $0.category == category }
    }
    
    func getItemsBySeason(_ season: Season) -> [Item] {
        return items.filter { $0.season == season || $0.season == .all }
    }
    
    
    func addOutfit(_ outfit: Outfit) {
        outfits.append(outfit)
        saveOutfits()
    }
    
    func updateOutfit(_ outfit: Outfit) {
        if let index = outfits.firstIndex(where: { $0.id == outfit.id }) {
            outfits[index] = outfit
            saveOutfits()
        }
    }
    
    func deleteOutfit(_ outfit: Outfit) {
        outfits.removeAll { $0.id == outfit.id }
        saveOutfits()
    }
    
    func getOutfitsByOccasion(_ occasion: Occasion) -> [Outfit] {
        return outfits.filter { $0.occasion == occasion }
    }
    
    func getOutfitsBySeason(_ season: Season) -> [Outfit] {
        return outfits.filter { $0.season == season || $0.season == .all }
    }
    
    func markOutfitAsWorn(_ outfit: Outfit) {
        if let index = outfits.firstIndex(where: { $0.id == outfit.id }) {
            outfits[index].lastWorn = Date()
            saveOutfits()
        }
    }
    
    
    func searchItems(query: String) -> [Item] {
        if query.isEmpty {
            return items
        }
        return items.filter { item in
            item.name.localizedCaseInsensitiveContains(query) ||
            item.brand.localizedCaseInsensitiveContains(query) ||
            item.color.localizedCaseInsensitiveContains(query)
        }
    }
    
    func searchOutfits(query: String) -> [Outfit] {
        if query.isEmpty {
            return outfits
        }
        return outfits.filter { outfit in
            outfit.name.localizedCaseInsensitiveContains(query) ||
            outfit.notes.localizedCaseInsensitiveContains(query)
        }
    }
    
    
    var totalItems: Int {
        return items.count
    }
    
    var totalOutfits: Int {
        return outfits.count
    }
    
    var favoriteOutfits: [Outfit] {
        return outfits.filter { $0.isFavorite }
    }
    
    var recentlyWornOutfits: [Outfit] {
        return outfits
            .filter { $0.lastWorn != nil }
            .sorted { ($0.lastWorn ?? Date.distantPast) > ($1.lastWorn ?? Date.distantPast) }
    }
    
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            items = decoded
        }
    }
    
    private func saveOutfits() {
        if let encoded = try? JSONEncoder().encode(outfits) {
            UserDefaults.standard.set(encoded, forKey: outfitsKey)
        }
    }
    
    private func loadOutfits() {
        if let data = UserDefaults.standard.data(forKey: outfitsKey),
           let decoded = try? JSONDecoder().decode([Outfit].self, from: data) {
            outfits = decoded
        }
    }
}


