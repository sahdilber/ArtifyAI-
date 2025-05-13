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
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    VStack(spacing: 8) {
                        Image("AppLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .shadow(radius: 5)

                        LinearGradient(colors: [.pink, .purple, .blue], startPoint: .leading, endPoint: .trailing)
                            .mask(
                                Text("ArtifyAI")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                            )
                            .frame(height: 50)
                    }
                    .padding(.top)

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

                    Button("🌀 Dönüştür") {
                        print("🟡 Dönüştür butonuna basıldı")
                        print("🧠 selectedImage: \(selectedImage != nil), selectedArtist: \(selectedArtist ?? "nil")")

                        if let image = selectedImage,
                           let artist = selectedArtist,
                           let styleImage = getStyleImage(for: artist) {
                            print("📤 API isteği gönderiliyor...")
                            sendImagesToServer(contentImage: image, styleImage: styleImage) { stylized in
                                if let result = stylized {
                                    DispatchQueue.main.async {
                                        print("✅ API'den stilize görsel geldi")
                                        transformedImage = result
                                        UIImageWriteToSavedPhotosAlbum(result, nil, nil, nil)
                                        showSaveAlert = true
                                        showBeforeAfter = true
                                    }
                                } else {
                                    print("❌ Görsel dönüştürülemedi")
                                }
                            }
                        } else {
                            print("⚠️ Gerekli bilgiler eksik")
                        }
                    }
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

    func getStyleImage(for artist: String) -> UIImage? {
        switch artist {
        case "🎨 Van Gogh":
            return UIImage(named: "vangogh_style")
        case "🖌 Picasso":
            return UIImage(named: "picasso_style")
        default:
            return nil
        }
    }

    func sendImagesToServer(contentImage: UIImage, styleImage: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "http://172.16.97.120:5050/stylize") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let resizedContent = contentImage.resized(toWidth: 512)
        let resizedStyle = styleImage.resized(toWidth: 512)

        let contentData = resizedContent.jpegData(compressionQuality: 1.0)!
        let styleData = resizedStyle.jpegData(compressionQuality: 1.0)!

        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"content_image\"; filename=\"content.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(contentData)
        body.append("\r\n")

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"style_image\"; filename=\"style.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(styleData)
        body.append("\r\n")

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let base64String = json["stylized_image"] as? String,
                  let imageData = Data(base64Encoded: base64String),
                  let image = UIImage(data: imageData) else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
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

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        let size = CGSize(width: width, height: height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? self
    }
}

#Preview {
    ContentView()
}

