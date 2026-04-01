import SwiftUI

struct ItemCard: View {
    let item: Item
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 8) {
                if let imageData = item.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipped()
                        .cornerRadius(8)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: item.category.icon)
                            .font(.title.bold())
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.caption)

                        .lineLimit(1)
                    
                    Text(item.brand)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack {
                        Circle()
                            .fill(Color(item.color.lowercased()))
                            .frame(width: 12, height: 12)
                        
                        Text(item.color)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundColor(item.season.color)
                        
                        Text(item.season.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 120, alignment: .leading)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            ItemDetailView(item: item)
        }
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
    
    return ItemCard(item: sampleItem)
        .padding()
}


