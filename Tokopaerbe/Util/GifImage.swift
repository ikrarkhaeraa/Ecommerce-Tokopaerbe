import Foundation
import SwiftUI
import SwiftUI
import UIKit
import FLAnimatedImage


struct GIFImage: UIViewRepresentable {
    private let name: String

    init(name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let gifImageView = FLAnimatedImageView()
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gifImageView)
        
        NSLayoutConstraint.activate([
            gifImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            gifImageView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        if let path = Bundle.main.path(forResource: name, ofType: "gif"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            let gifImage = FLAnimatedImage(animatedGIFData: data)
            gifImageView.animatedImage = gifImage
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
