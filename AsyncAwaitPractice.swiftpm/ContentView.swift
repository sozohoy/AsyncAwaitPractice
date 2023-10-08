import SwiftUI

struct ContentView: View {
    let randomImageUrlBase: String = "https://source.unsplash.com/random/?"
    let session = URLSession.shared
    
    @State var image: UIImage? = nil
    @State var thumbnail: UIImage? = nil
    @State var isLoading: Bool = false
    @State var query: String = ""
    
    private func asyncLoadRandomImage() async throws {
        isLoading.toggle()
        guard let requestUrl = URL(string: randomImageUrlBase + query) else { return }
        do {
            let (data, _) = try await session.data(from: requestUrl)
            guard let uiImage = UIImage(data: data) else {
                print(" Hi ")
                return }
            image = uiImage
            thumbnail = await uiImage.byPreparingThumbnail(ofSize: CGSize(width: 100,
                                                                          height: 100))
            isLoading.toggle()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadRandomImage() {
        let url = randomImageUrlBase + query
        guard let requestURL = URL(string: url) else { return }
        isLoading.toggle()
        session.dataTask(with: requestURL) { data, response, error in
            guard
                error == nil,
                let data = data,
                response != nil
            else { return }
            image = UIImage(data: data)
            thumbnail = UIImage(data: data)
            thumbnail?.prepareThumbnail(of: CGSize(width: 100, height: 100)) { _ in
                isLoading.toggle()
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
            }
            VStack {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                }
                if isLoading {
                    ProgressView()
                } else {
                    Text("ready")
                }
                
                TextField("baseball", text: $query)
                
                Button {
                    Task {
                        asyncLoadRandomImage
                    }
                } label: {
                    Text(isLoading ? "로딩 중..." : "불러오기")
                }
                .padding()
            }
        }
    }
    
}
