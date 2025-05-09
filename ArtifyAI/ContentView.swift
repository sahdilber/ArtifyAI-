import SwiftUI

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var transformedImage: UIImage?
    @State private var selectedArtist: String? = nil
    @State private var showSaveAlert = false
    @State private var showBeforeAfter = false

    let artists = ["🎨 Van Gogh", "🖌 Picasso", "🌸 Monet", "😱 Munch", "🌟 Klimt", "🌀 Dali"]

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Giriş Logo ve Başlık
                    VStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .shadow(radius: 5)
                            .transition(.scale)

                        LinearGradient(
                            colors: [.pink, .purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("ArtifyAI")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                        )
                        .frame(height: 50)
                    }
                    .padding(.top)
                    .animation(.easeInOut(duration: 0.5), value: selectedImage)

                    // Seçilen ve Dönüştürülmüş Görseller Karşılaştırmalı
                    if let original = selectedImage {
                        VStack {
                            if showBeforeAfter, let output = transformedImage {
                                HStack(spacing: 10) {
                                    VStack {
                                        Text("Önce")
                                        Image(uiImage: original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(12)
                                    }
                                    VStack {
                                        Text("Sonra")
                                        Image(uiImage: output)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(12)
                                    }
                                }
                            } else {
                                Image(uiImage: original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .cornerRadius(20)
                                    .shadow(radius: 5)
                                    .padding()
                            }

                            if transformedImage != nil {
                                Button("↔ Önce/Sonra Karşılaştır") {
                                    withAnimation {
                                        showBeforeAfter.toggle()
                                    }
                                }
                            }
                        }
                    } else {
                        Text("Henüz fotoğraf seçilmedi")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    // Fotoğraf Seç
                    Button("📷 Fotoğraf Seç") {
                        showImagePicker = true
                    }
                    .buttonStyle(PressableButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)

                    // Sanatçı Seçimi
                    Text("Bir sanatçı seç:")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(artists, id: \.self) { artist in
                                Text(artist)
                                    .padding(10)
                                    .background(selectedArtist == artist ? Color.purple : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedArtist == artist ? .white : .primary)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        selectedArtist = artist
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }

                    if let selectedArtist = selectedArtist {
                        Text("Seçilen sanatçı: \(selectedArtist)")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 8)
                    }

                    // Dönüştür Butonu
                    Button("🌀 Dönüştür") {
                        if let image = selectedImage {
                            // Geçici simülasyon: aynı fotoğrafı dönüştürülmüş gibi göster
                            transformedImage = image
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            showSaveAlert = true
                        }
                    }
                    .disabled(selectedImage == nil || selectedArtist == nil)
                    .buttonStyle(PressableButtonStyle())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 4)
                    .padding(.horizontal)
                    .alert("Başarılı", isPresented: $showSaveAlert) {
                        Button("Tamam", role: .cancel) {}
                    } message: {
                        Text("Fotoğraf başarıyla galerinize kaydedildi.")
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
