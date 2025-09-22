import SwiftUI

struct DetailsView: View {
    let skatePark: SkatePark
    @State private var currentPhotoIndex = 0
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var previousParkId: String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // Park name
                Text(skatePark.name ?? "Unknown Park")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(height: 17)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .padding(.horizontal, 16)
                
                // Info labels
                VStack(alignment: .leading, spacing: 6) {
                    Text(buildLineOneText())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.196, green: 0.804, blue: 0.196)) // Lime green
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        copyAddress()
                    }) {
                        Text(skatePark.address ?? "")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 0.196, green: 0.804, blue: 0.196)) // Lime green
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black)
                            .cornerRadius(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Skatepark elements field with 2-3 lines reserved
                    if let elements = skatePark.elements, !elements.isEmpty {
                        Text("Elements: \(elements)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 0.196, green: 0.804, blue: 0.196)) // Lime green
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black)
                            .cornerRadius(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                    } else {
                        // Empty space placeholder to maintain consistent button placement
                        Text("")
                            .font(.system(size: 11, weight: .medium))
                            .frame(height: 40) // Reserve space for 2 lines
                    }
                }
                .padding(.horizontal, 16)
                
                // Buttons moved here
                HStack(spacing: 12) {
                    Button("DIRECTIONS") {
                        openDirections()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.system(size: 11, weight: .medium))
                    .frame(height: 28)
                    .frame(maxWidth: 100)
                    
                    Button("WEBSITE") {
                        openWebsite()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.system(size: 11, weight: .medium))
                    .frame(height: 28)
                    .frame(maxWidth: 100)
                }
                .padding(.horizontal, 16)
                
                // Zoomable Image
                ZoomableImageView(
                    photos: skatePark.photos ?? ["loading"],
                    currentIndex: $currentPhotoIndex,
                    scale: $scale,
                    offset: $offset,
                    lastOffset: $lastOffset,
                    lastScale: $lastScale
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 3)
            }
        }
        .background(Color(red: 0.33, green: 0.33, blue: 0.33))
        .onAppear {
            // Reset zoom when park changes
            if previousParkId != skatePark.id {
                resetZoom()
                previousParkId = skatePark.id
            }
        }
        .onChange(of: skatePark.id) { newParkId in
            // Reset zoom when park changes
            if previousParkId != newParkId {
                resetZoom()
                previousParkId = newParkId
            }
        }
    }
    
    private func resetZoom() {
        scale = 1.0
        offset = .zero
        lastOffset = .zero
        lastScale = 1.0
        currentPhotoIndex = 0
    }
    
    private func buildLineOneText() -> String {
        let builder = skatePark.builder ?? "n/a"
        let sqft = skatePark.sqft ?? "n/a"
        let lights = skatePark.lights ?? "n/a"
        let covered = skatePark.covered ?? "n/a"
        return "Builder: \(builder) | SqFt: \(sqft) | Lights: \(lights) | Covered: \(covered)"
    }
    
    private func openDirections() {
        guard let latitude = skatePark.latitude,
              let longitude = skatePark.longitude,
              let url = URL(string: "https://www.google.com/search?q=\(latitude)%2C\(longitude)") else { return }
        UIApplication.shared.open(url)
    }
    
    private func openWebsite() {
        guard let urlString = skatePark.url,
              let range = urlString.range(of: "http[^\\s]*", options: .regularExpression),
              let url = URL(string: String(urlString[range])) else { return }
        UIApplication.shared.open(url)
    }
    
    private func copyAddress() {
        UIPasteboard.general.string = skatePark.address
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

struct ZoomableImageView: View {
    let photos: [String]
    @Binding var currentIndex: Int
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    @Binding var lastScale: CGFloat
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if let image = image {
                    ZStack {
                        Color.black
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale, anchor: .center)
                            .offset(x: offset.width, y: offset.height)
                    }
                    .clipped()
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    
                                    let newScale = scale * delta
                                    scale = max(1.0, min(newScale, 5.0))
                                    
                                    // Always zoom from screen center - no offset adjustment needed
                                    // The anchor: .center in scaleEffect handles this automatically
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    
                                    withAnimation(.spring()) {
                                        if scale <= 1.0 {
                                            scale = 1.0
                                            offset = .zero
                                            lastOffset = .zero
                                        } else {
                                            constrainOffset(geometry: geometry)
                                            lastOffset = offset
                                        }
                                    }
                                },
                            
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1.0 {
                                        let newOffset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                        offset = newOffset
                                    }
                                }
                                .onEnded { _ in
                                    if scale > 1.0 {
                                        constrainOffset(geometry: geometry)
                                        lastOffset = offset
                                    }
                                }
                        )
                    )
                    .onTapGesture(count: 2) {
                        // Double tap to reset zoom
                        withAnimation(.spring()) {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
                    .onTapGesture(count: 1) {
                        // Single tap to cycle photos
                        nextPhoto()
                    }
                    .onAppear {
                        loadImage()
                    }
                } else {
                    Rectangle()
                        .fill(Color.black)
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                        .onAppear {
                            loadImage()
                        }
                }
            }
        }
        .onChange(of: currentIndex) { _ in
            // Reset zoom and load new image
            withAnimation(.easeInOut(duration: 0.2)) {
                scale = 1.0
                offset = .zero
                lastOffset = .zero
                lastScale = 1.0
            }
            loadImage()
        }
    }
    
    private func constrainOffset(geometry: GeometryProxy) {
        // Calculate the bounds for panning based on the scaled image
        let scaledWidth = geometry.size.width * scale
        let scaledHeight = geometry.size.height * scale
        
        let maxX = max(0, (scaledWidth - geometry.size.width) / 2)
        let maxY = max(0, (scaledHeight - geometry.size.height) / 2)
        
        offset = CGSize(
            width: max(-maxX, min(maxX, offset.width)),
            height: max(-maxY, min(maxY, offset.height))
        )
    }
    
    private func nextPhoto() {
        currentIndex = (currentIndex + 1) % photos.count
    }
    
    private func loadImage() {
        guard currentIndex < photos.count else { return }
        
        let imageUrl = photos[currentIndex]
        
        // Check if it's a local image first
        if let localImage = UIImage(named: imageUrl) {
            self.image = localImage
            return
        }
        
        // Prepare URL string
        let finalUrlString: String
        if imageUrl.hasPrefix("https://") || imageUrl.hasPrefix("http://") {
            finalUrlString = imageUrl
        } else {
            finalUrlString = SkatePark.imageHostUrl + imageUrl
        }
        
        guard let url = URL(string: finalUrlString) else { return }
        
        // Async image loading
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let loadedImage = UIImage(data: data) {
                    await MainActor.run {
                        self.image = loadedImage
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }
}
