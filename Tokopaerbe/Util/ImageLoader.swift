//
//  ImageLoader.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 18/06/24.
//

import SwiftUI

struct ImageLoader: View {
    
    @Binding var contentMode: String
    let urlString: String

    @State private var image: UIImage? = nil
    @State private var lastUrl: String = ""

    var body: some View {
        Group {
           
            if let image = image {
                let _ = loadImage()
                
                if contentMode == "fill" {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if contentMode == "fit" {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if contentMode == "circle36" {
                    Image(uiImage: image)
                      .resizable()
                      .frame(width: 36, height: 36)
                      .clipShape(Circle())
                }
                
                
            } else {
                ProgressView()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard let url = URL(string: urlString) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                }
            }
        }
        task.resume()
    }
}

