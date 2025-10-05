//
//  Outfit.swift
//  OUTFITS
//
//  Created by Antoine Gallo on 30/09/2025.
//

import Foundation
import SwiftUI

struct Outfit: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var items: [Item]
    var season: Season
    var occasion: Occasion
    var rating: Int // 1-5 étoiles
    var dateCreated: Date
    var lastWorn: Date?
    var notes: String
    var isFavorite: Bool
    
    init(name: String, items: [Item] = [], season: Season, occasion: Occasion, rating: Int = 3, notes: String = "", isFavorite: Bool = false) {
        self.name = name
        self.items = items
        self.season = season
        self.occasion = occasion
        self.rating = rating
        self.dateCreated = Date()
        self.lastWorn = nil
        self.notes = notes
        self.isFavorite = isFavorite
    }
    
    var totalItems: Int {
        return items.count
    }
    
    var hasCompleteOutfit: Bool {
        let hasTop = items.contains { $0.category == .top || $0.category == .dress }
        let hasBottom = items.contains { $0.category == .bottom }
        let hasShoes = items.contains { $0.category == .shoes }
        
        return hasTop && (hasBottom || items.contains { $0.category == .dress }) && hasShoes
    }
}

enum Occasion: String, CaseIterable, Codable {
    case casual = "Décontracté"
    case work = "Travail"
    case formal = "Formel"
    case party = "Soirée"
    case sport = "Sport"
    case travel = "Voyage"
    case date = "Rendez-vous"
    case home = "Maison"
    
    var icon: String {
        switch self {
        case .casual: return "person.crop.circle"
        case .work: return "briefcase"
        case .formal: return "suit.heart"
        case .party: return "party.popper"
        case .sport: return "figure.run"
        case .travel: return "airplane"
        case .date: return "heart"
        case .home: return "house"
        }
    }
    
    var color: Color {
        switch self {
        case .casual: return .blue
        case .work: return .gray
        case .formal: return .black
        case .party: return .purple
        case .sport: return .green
        case .travel: return .orange
        case .date: return .pink
        case .home: return .brown
        }
    }
}

