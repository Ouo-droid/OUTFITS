import Foundation
import SwiftUI

struct Item: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var brand: String
    var category: ItemCategory
    var color: String
    var size: String
    var season: Season
    var imageData: Data?
    var dateAdded: Date
    var notes: String
    
    init(name: String, brand: String, category: ItemCategory, color: String, size: String, season: Season, imageData: Data? = nil, notes: String = "") {
        self.name = name
        self.brand = brand
        self.category = category
        self.color = color
        self.size = size
        self.season = season
        self.imageData = imageData
        self.dateAdded = Date()
        self.notes = notes
    }
}

enum ItemCategory: String, CaseIterable, Codable {
    case top = "Haut"
    case bottom = "Bas"
    case dress = "Robe"
    case outerwear = "Veste/Manteau"
    case shoes = "Chaussures"
    case accessories = "Accessoires"
    case underwear = "Sous-vêtements"
    case sportswear = "Sport"
    
    var icon: String {
        switch self {
        case .top: return "tshirt"
        case .bottom: return "figure.walk"
        case .dress: return "figure.dress.line.vertical.figure"
        case .outerwear: return "jacket"
        case .shoes: return "shoe.2"
        case .accessories: return "bag"
        case .underwear: return "figure.arms.open"
        case .sportswear: return "figure.run"
        }
    }
}

enum Season: String, CaseIterable, Codable {
    case spring = "Printemps"
    case summer = "Été"
    case autumn = "Automne"
    case winter = "Hiver"
    case all = "Toutes saisons"
    
    var color: Color {
        switch self {
        case .spring: return .green
        case .summer: return .yellow
        case .autumn: return .orange
        case .winter: return .blue
        case .all: return .gray
        }
    }
}


