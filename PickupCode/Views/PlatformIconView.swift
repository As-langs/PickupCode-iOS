import SwiftUI
import UIKit

struct PlatformIconView: View {
    let name: String
    var size: CGFloat = 34
    
    var body: some View {
        if let uiImage = Self.loadImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            Image(systemName: "app.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(.gray.opacity(0.4))
        }
    }
    
    static func loadImage(named name: String) -> UIImage? {
        // 1. Try Assets catalog
        if let img = UIImage(named: name) {
            return img
        }
        
        // 2. Try root bundle with .png
        if let path = Bundle.main.path(forResource: name, ofType: "png"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        
        // 3. Try root bundle without extension
        if let path = Bundle.main.path(forResource: name, ofType: nil),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        
        // 4. Try inside Resources or Images subdirectory
        if let subPath = Bundle.main.path(forResource: name, ofType: "png", inDirectory: "Images"),
           let img = UIImage(contentsOfFile: subPath) {
            return img
        }
        
        return nil
    }
}
