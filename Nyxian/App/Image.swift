/*
 MIT License

 Copyright (c) 2025 SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import SwiftUI
import Combine
import UIKit
import Foundation

struct AsyncImageLoaderView: View {
   @StateObject private var imageLoader = ImageLoader()
   private let urlString: String
   private let width: CGFloat?
   private let height: CGFloat?

   init(urlString: String, width: CGFloat? = nil, height: CGFloat? = nil) {
       self.urlString = urlString
       self.width = width
       self.height = height
   }

   private var url: URL? {
       URL(string: urlString)
   }

   var body: some View {
       if let uiImage = imageLoader.image {
           Image(uiImage: uiImage)
               .resizable()
               .aspectRatio(contentMode: .fit)
               .frame(width: width, height: height)
               .clipShape(Circle())
       } else {
           ProgressView()
               .aspectRatio(contentMode: .fit)
               .frame(width: width, height: height)
               .onAppear {
                   if let url = url {
                       imageLoader.loadImage(from: url)
                   }
               }
       }
   }
}

class ImageLoader: ObservableObject {
   @Published var image: UIImage?

   private var cancellable: AnyCancellable?
   private let maxRetries = 3
   private let retryDelay = 2.0

   func loadImage(from url: URL) {
       cancellable?.cancel()

       cancellable = URLSession.shared.dataTaskPublisher(for: url)
           .tryMap { (data, response) in
               guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                   throw URLError(.badServerResponse)
               }
               return data
           }
           .compactMap { UIImage(data: $0) }
           .receive(on: DispatchQueue.main)
           .retry(maxRetries)
           .catch { [weak self] error -> AnyPublisher<UIImage?, Never> in
               print("Failed to load image: \(error.localizedDescription)")
               return Just(nil).delay(for: .seconds(self?.retryDelay ?? 2.0), scheduler: RunLoop.main).eraseToAnyPublisher()
           }
           .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] loadedImage in
               self?.image = loadedImage
           })
   }

   deinit {
       cancellable?.cancel()
   }
}
