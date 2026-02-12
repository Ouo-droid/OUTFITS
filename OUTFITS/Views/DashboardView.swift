import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var wardrobeManager: WardrobeManager
    @State private var showingAddItem = false
    @State private var showingCreateOutfit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    quickActionsSection
                    
                    recentOutfitsSection
                    
                    recentItemsSection
                }
                .padding()
            }
            .navigationTitle("Mon Dressing")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Ajouter un article") {
                            showingAddItem = true
                        }
                        Button("Créer un outfit") {
                            showingCreateOutfit = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView()
                .environmentObject(wardrobeManager)
        }
        .sheet(isPresented: $showingCreateOutfit) {
            CreateOutfitView()
                .environmentObject(wardrobeManager)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Bonjour !")
                        .font(.title2.bold())

                    Text("Organisez votre style")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title.bold())
                    .foregroundColor(.purple)
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Articles",
                    value: "\(wardrobeManager.totalItems)",
                    icon: "tshirt",
                    color: .blue
                )
                
                StatCard(
                    title: "Outfits",
                    value: "\(wardrobeManager.totalOutfits)",
                    icon: "figure.dress.line.vertical.figure",
                    color: .purple
                )
                
                StatCard(
                    title: "Favoris",
                    value: "\(wardrobeManager.favoriteOutfits.count)",
                    icon: "heart.fill",
                    color: .pink
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions rapides")
                .font(.headline.bold())

            
            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Ajouter article",
                    icon: "plus.circle",
                    color: .blue
                ) {
                    showingAddItem = true
                }
                
                QuickActionButton(
                    title: "Créer outfit",
                    icon: "figure.dress.line.vertical.figure",
                    color: .purple
                ) {
                    showingCreateOutfit = true
                }
            }
        }
    }
    
    private var recentOutfitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Outfits récents")
                    .font(.headline.bold())

                Spacer()
                NavigationLink("Voir tout") {
                    OutfitsView()
                        .environmentObject(wardrobeManager)
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
            
            if wardrobeManager.outfits.isEmpty {
                EmptyStateView(
                    icon: "figure.dress.line.vertical.figure",
                    title: "Aucun outfit",
                    subtitle: "Créez votre premier outfit !"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(wardrobeManager.outfits.prefix(5)) { outfit in
                            OutfitCard(outfit: outfit)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var recentItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Articles récents")
                    .font(.headline.bold())

                Spacer()
                NavigationLink("Voir tout") {
                    WardrobeView()
                        .environmentObject(wardrobeManager)
                }
                .font(.caption)
                .foregroundColor(.purple)
            }
            
            if wardrobeManager.items.isEmpty {
                EmptyStateView(
                    icon: "tshirt",
                    title: "Aucun article",
                    subtitle: "Ajoutez votre premier article !"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(wardrobeManager.items.prefix(5)) { item in
                            ItemCard(item: item)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())

            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2.bold())
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)

                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline.bold())

            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DashboardView_Previews: PreviewProvider { static var previews: some View {
    DashboardView()
        .environmentObject(WardrobeManager())
}

}