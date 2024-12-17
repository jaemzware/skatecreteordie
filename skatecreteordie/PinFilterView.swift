//
//  PinFilterView.swift
//  skatecreteordie
//
//  Created by JAMES ARASIM on 12/16/24.
//  Copyright © 2024 JAMES K ARASIM. All rights reserved.
//

import SwiftUI

struct PinFilterView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelection: (String?) -> Void  // Changed to accept optional String
    let pinImages: [String]
    
    var body: some View {
        NavigationView {
            List {
                // "All Skateparks" as first item
                Button(action: {
                    onSelection(nil)
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "map")  // Using map icon instead of filter icon
                            .foregroundColor(.blue)
                        Text("All Skateparks")
                        Spacer()
                    }
                }
                
                // Rest of pin images
                ForEach(pinImages, id: \.self) { pinImage in
                    Button(action: {
                        onSelection(pinImage)
                        dismiss()
                    }) {
                        HStack {
                            Image(pinImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                            Text(pinImage)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Filter Skateparks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
