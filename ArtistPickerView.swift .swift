//
//  ArtistPickerView.swift .swift
//  ArtifyAI
//
//  Created by Dilber Şah on 8.05.2025.
//
import SwiftUI

struct ArtistPickerView: View {
    let artists: [String]
    @Binding var selectedArtist: String?
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(artists, id: \.self) { artist in
                        Button(action: {
                            selectedArtist = artist
                            isPresented = false
                        }) {
                            Text(artist)
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .foregroundColor(.primary)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Sanatçı Seç")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
import Foundation
