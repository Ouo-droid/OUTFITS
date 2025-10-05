//
//  ContentView.swift
//  OUTFITS
//
//  Created by Antoine  Gallo on 30/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var wardrobeManager = WardrobeManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Vue principale - Dashboard
            DashboardView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "house")
                    Text("Accueil")
                }
                .tag(0)
            
            // Vue du dressing
            WardrobeView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "tshirt")
                    Text("Dressing")
                }
                .tag(1)
            
            // Vue des outfits
            OutfitsView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "figure.dress.line.vertical.figure")
                    Text("Outfits")
                }
                .tag(2)
            
            // Vue des favoris
            FavoritesView()
                .environmentObject(wardrobeManager)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favoris")
                }
                .tag(3)
        }
        .accentColor(.purple)
    }   
}

#Preview {
    ContentView()
}
