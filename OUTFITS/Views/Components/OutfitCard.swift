import SwiftUI

struct OutfitCard: View {
    let outfit: Outfit
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [
                                outfit.occasion.color.opacity(0.3),
                                outfit.occasion.color.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 140, height: 100)
                    
                    VStack(spacing: 4) {
                        Image(systemName: outfit.occasion.icon)
                            .font(.title2)
                            .foregroundColor(outfit.occasion.color)
                        
                        Text("\(outfit.totalItems) articles")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(outfit.name)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        if outfit.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.caption2)
                                .foregroundColor(.pink)
                        }
                    }
                    
                    Text(outfit.occasion.rawValue)
                        .font(.caption2)
                        .foregroundColor(outfit.occasion.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(outfit.occasion.color.opacity(0.2))
                        .cornerRadius(4)
                    
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= outfit.rating ? "star.fill" : "star")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    if let lastWorn = outfit.lastWorn {
                        Text("Porté le \(lastWorn, formatter: dateFormatter)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 140, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            OutfitDetailView(outfit: outfit)
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    let sampleOutfit = Outfit(
        name: "Look décontracté",
        items: [],
        season: .summer,
        occasion: .casual,
        rating: 4
    )
    
    return OutfitCard(outfit: sampleOutfit)
        .padding()
}


