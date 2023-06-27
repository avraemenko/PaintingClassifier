import SwiftUI
import UIKit
import CoreML
import Vision



struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var classificationLabel: String = ""

    var body: some View {
        VStack {
            Text("Painter Classifier")
                .font(.largeTitle)
                .padding()

            Image(systemName: "paintpalette.fill")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .clipped()
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 5)
                    )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.blue, lineWidth: 5)
                    .frame(width: 300, height: 300)
                    .overlay(
                        Text("✨your painting✨")
                            .foregroundColor(.blue)
                    )
            }

            Button("Select painting") {
                self.showImagePicker = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text("Painted by: \(classificationLabel)")
                .padding()
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePicker(selectedImage: self.$image)
        }
    }

    func loadImage() {
        guard let inputImage = image else { return }
        classify(image: inputImage)
    }

    func classify(image: UIImage) {
        // Load the ML model file
        guard let model = try? VNCoreMLModel(for: ArtistClassifier().model) else {
            self.classificationLabel = "Failed to load model"
            return
        }
        
        // Create a request for the ML model
        let request = VNCoreMLRequest(model: model) {  request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                self.classificationLabel = "Classification failed"
                return
            }
            DispatchQueue.main.async {
                self.classificationLabel = topResult.identifier.replacingOccurrences(of: "_", with: " ")
            }
        }
        
        // Perform the request
        guard let ciImage = CIImage(image: image) else { return }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification.\n\(error.localizedDescription)")
        }
    }
}
