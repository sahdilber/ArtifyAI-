import SwiftUI

struct ErrorMessage: Identifiable {
    var id = UUID()
    let message: String
}

struct ContentView: View {
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var transformedImage: UIImage?
    @State private var selectedArtist: String? = nil
    @State private var showDownloadOption = false
    @State private var showBeforeAfter = false
    @State private var isLoading = false
    @State private var showFullScreenImage = false
    @State private var errorMessage: ErrorMessage? = nil
    @State private var showWelcome = true
    @Environment(\.colorScheme) var colorScheme

    let artists = ["🎨 Van Gogh", "🖌 Picasso", "🌸 Monet", "😱 Munch", "🌟 Klimt", "🌀 Dali"]

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .indigo, .purple], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if showWelcome {
                VStack(spacing: 20) {
                    Spacer()
                    Text("🎨 Hoş Geldiniz!")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .transition(.scale)
                    Text("ArtifyAI ile fotoğraflarınızı sanat eserlerine dönüştürün.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding()
                    Button("Başla") {
                        withAnimation {
                            showWelcome = false
                        }
                    }
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    Spacer()
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .shadow(radius: 5)

                            Text("ArtifyAI")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 10)

                        if let original = selectedImage, let output = transformedImage {
                            VStack(spacing: 10) {
                                HStack(spacing: 10) {
                                    VStack {
                                        Text("Önce").foregroundColor(.white)
                                        Image(uiImage: original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(12)
                                    }
                                    VStack {
                                        Text("Sonra").foregroundColor(.white)
                                        Image(uiImage: output)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .cornerRadius(12)
                                            .onTapGesture {
                                                showFullScreenImage = true
                                            }
                                    }
                                }

                                Button(action: {
                                    UIImageWriteToSavedPhotosAlbum(output, nil, nil, nil)
                                    showDownloadOption = true
                                }) {
                                    Label("Kaydet", systemImage: "square.and.arrow.down.fill")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 3)
                                }
                                .padding(.top)
                            }
                        } else if let original = selectedImage {
                            Image(uiImage: original)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(20)
                                .shadow(radius: 5)
                                .padding()
                        } else {
                            Text("Henüz fotoğraf seçilmedi")
                                .foregroundColor(.white.opacity(0.7))
                                .padding()
                        }

                        if isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("🖌 \(selectedArtistName()) fırçası çalışıyor…")
                                    .italic()
                                    .foregroundColor(.white)
                                    .transition(.opacity)
                            }
                            .padding()
                        }

                        Button("📷 Fotoğraf Seç") {
                            showImagePicker = true
                            transformedImage = nil
                        }
                        .buttonStyle(PressableButtonStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .padding(.horizontal)

                        Text("Bir sanatçı seç:")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(artists, id: \.self) { artist in
                                    Text(artist)
                                        .padding(12)
                                        .background(selectedArtist == artist ? Color.pink : Color.white.opacity(0.2))
                                        .foregroundColor(selectedArtist == artist ? .white : .white)
                                        .cornerRadius(12)
                                        .shadow(radius: 2)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                selectedArtist = artist
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }

                        Button("🌀 Dönüştür") {
                            if let image = selectedImage,
                               let artist = selectedArtist,
                               let styleImage = getStyleImage(for: artist) {
                                isLoading = true
                                sendImagesToServer(contentImage: image, styleImage: styleImage) { stylized in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                        if let result = stylized {
                                            transformedImage = result
                                            showBeforeAfter = false
                                        } else {
                                            errorMessage = ErrorMessage(message: "❌ Görsel dönüştürülemedi. Lütfen tekrar deneyin.")
                                        }
                                    }
                                }
                            } else {
                                errorMessage = ErrorMessage(message: "⚠️ Lütfen fotoğraf ve sanatçı seçtiğinizden emin olun.")
                            }
                        }
                        .buttonStyle(PressableButtonStyle())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .sheet(isPresented: $showFullScreenImage) {
            if let image = transformedImage {
                VStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .ignoresSafeArea()
                    Button("Kapat") {
                        showFullScreenImage = false
                    }
                    .padding()
                }
            }
        }
        .toast(isPresented: $showDownloadOption, message: "📸 Galeriye kaydedildi.")
        .alert(item: $errorMessage) { error in
            Alert(title: Text("Hata"), message: Text(error.message), dismissButton: .default(Text("Tamam")))
        }
    }

    func selectedArtistName() -> String {
        guard let artist = selectedArtist else { return "Sanatçının" }
        switch artist {
        case "🎨 Van Gogh": return "Van Gogh’un"
        case "🖌 Picasso": return "Picasso’nun"
        case "🌸 Monet": return "Monet’nin"
        case "😱 Munch": return "Munch’un"
        case "🌟 Klimt": return "Klimt’in"
        case "🌀 Dali": return "Dali’nin"
        default: return "Sanatçının"
        }
    }
}

    func getStyleImage(for artist: String) -> UIImage? {
        switch artist {
        case "🎨 Van Gogh": return UIImage(named: "vangogh_style")
        case "🖌 Picasso": return UIImage(named: "picasso_style")
        default: return nil
        }
    }

    func sendImagesToServer(contentImage: UIImage, styleImage: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: "http://192.168.1.102:5050/stylize") else { return }
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


// MARK: - Yardımcı Görünümler ve Uzantılar

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

extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                VStack {
                    Spacer()
                    Text(message)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom))
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isPresented.wrappedValue = false
                    }
                }
            }
        }
    }
}

struct SliderComparisonView: View {
    var original: UIImage
    var transformed: UIImage
    @State private var sliderValue: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Image(uiImage: transformed)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()

                Image(uiImage: original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width * sliderValue, height: geometry.size.height)
                    .clipped()

                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2)
                    .position(x: geometry.size.width * sliderValue, y: geometry.size.height / 2)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let newValue = value.location.x / geometry.size.width
                        sliderValue = min(max(newValue, 0), 1)
                    }
            )
        }
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    ContentView()
}
