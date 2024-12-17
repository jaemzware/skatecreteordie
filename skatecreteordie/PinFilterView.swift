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
    let onSelection: (String) -> Void
    let pinImages: [String]
    
    var body: some View {
        NavigationView {
            List(pinImages, id: \.self) { pinImage in
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
            .navigationTitle("Select Pin Image")
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
