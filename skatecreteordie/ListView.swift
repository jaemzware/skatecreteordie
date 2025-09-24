import SwiftUI

struct ListView: View {
    let skateParks: [SkatePark]
    let currentFilter: String?
    let onParkSelected: (SkatePark) -> Void
    
    @State private var searchText = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }
    
    // Computed property for navigation title
    var navigationTitle: String {
        if let filter = currentFilter {
            return "Skate Parks - \(filter)"
        } else {
            return "Skate Parks"
        }
    }
    
    // Group skate parks by group, then sort by name within each group
    var groupedSkateParks: [(String, [SkatePark])] {
        let filtered = filteredSkateParks
        let grouped = Dictionary(grouping: filtered) { $0.group ?? "Unknown" }
        return grouped.map { (key, value) in
            (key, value.sorted { ($0.name ?? "") < ($1.name ?? "") })
        }.sorted { $0.0 < $1.0 }
    }
    
    // Filter parks based on search text
    var filteredSkateParks: [SkatePark] {
        if searchText.isEmpty {
            return skateParks
        } else {
            return skateParks.filter { park in
                (park.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (park.address?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (park.group?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sticky search bar
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: isIPad ? 20 : 16))
                        
                        TextField("Search parks, addresses, or locations...", text: $searchText)
                            .font(.system(size: isIPad ? 18 : 16))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.system(size: isIPad ? 16 : 14))
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Results count
                if !searchText.isEmpty {
                    HStack {
                        Text("\(filteredSkateParks.count) park\(filteredSkateParks.count == 1 ? "" : "s") found")
                            .font(.system(size: isIPad ? 16 : 14))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                
                // List of parks grouped by location
                List {
                    ForEach(groupedSkateParks, id: \.0) { group, parks in
                        Section {
                            ForEach(parks, id: \.id) { park in
                                ParkRowView(
                                    park: park,
                                    group: group,
                                    isIPad: isIPad,
                                    onTap: {
                                        onParkSelected(park)
                                    }
                                )
                            }
                        } header: {
                            GroupHeaderView(groupName: group, isIPad: isIPad)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures proper behavior on iPad
    }
}

struct GroupHeaderView: View {
    let groupName: String
    let isIPad: Bool
    
    var body: some View {
        HStack {
            // Group flag/image
            if let image = UIImage(named: groupName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: isIPad ? 60 : 40, height: isIPad ? 40 : 30)
                    .cornerRadius(4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: isIPad ? 60 : 40, height: isIPad ? 40 : 30)
                    .cornerRadius(4)
                    .overlay(
                        Text(String(groupName.prefix(2)))
                            .font(.system(size: isIPad ? 16 : 12, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            Text(groupName)
                .font(.system(size: isIPad ? 22 : 18, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.systemBackground))
    }
}

struct ParkRowView: View {
    let park: SkatePark
    let group: String
    let isIPad: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Group flag/image (smaller version for rows)
                if let image = UIImage(named: group) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isIPad ? 40 : 30, height: isIPad ? 30 : 20)
                        .cornerRadius(2)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: isIPad ? 40 : 30, height: isIPad ? 30 : 20)
                        .cornerRadius(2)
                        .overlay(
                            Text(String(group.prefix(2)))
                                .font(.system(size: isIPad ? 12 : 8, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(park.name ?? "Unknown Park")
                        .font(.system(size: isIPad ? 18 : 16, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(park.address ?? "No address")
                        .font(.system(size: isIPad ? 14 : 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: isIPad ? 16 : 14))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, isIPad ? 12 : 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preview for development
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleParks = [
            SkatePark(
                name: "Sample Park 1",
                address: "123 Main St, Sample City",
                id: "1",
                builder: "Builder A",
                sqft: "5000",
                lights: "Yes",
                covered: "No",
                url: "https://example.com",
                elements: "Bowl, Street",
                pinimage: "pin1",
                photos: ["photo1"],
                latitude: "47.6062",
                longitude: "-122.3321",
                group: "WA"
            ),
            SkatePark(
                name: "Sample Park 2",
                address: "456 Oak Ave, Another City",
                id: "2",
                builder: "Builder B",
                sqft: "3000",
                lights: "No",
                covered: "Yes",
                url: "https://example.com",
                elements: "Street, Vert",
                pinimage: "pin2",
                photos: ["photo2"],
                latitude: "45.5152",
                longitude: "-122.6784",
                group: "OR"
            )
        ]
        
        ListView(skateParks: sampleParks, currentFilter: nil) { park in
            print("Selected park: \(park.name ?? "Unknown")")
        }
    }
}
