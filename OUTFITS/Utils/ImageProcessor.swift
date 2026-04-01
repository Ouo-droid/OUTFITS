import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

class ImageProcessor {
    static func removeBackground(from image: UIImage) async -> UIImage? {
        // Run on background thread
        return await Task.detached(priority: .userInitiated) {
            guard let inputImage = CIImage(image: image) else { return nil }

            // Ensure we are using iOS 17+ API
            if #available(iOS 17.0, *) {
                let request = VNGenerateForegroundInstanceMaskRequest()
                let handler = VNImageRequestHandler(ciImage: inputImage, options: [:])

                do {
                    try handler.perform([request])
                    guard let result = request.results?.first else { return nil }

                    // Get the mask from the observation
                    let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                    let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)

                    // Blend the image with the mask
                    let filter = CIFilter.blendWithMask()
                    filter.inputImage = inputImage
                    filter.maskImage = maskImage
                    filter.backgroundImage = CIImage.empty()

                    guard let outputImage = filter.outputImage else { return nil }

                    let context = CIContext()
                    // Use inputImage.extent to avoid potential infinite extent issues
                    guard let cgImage = context.createCGImage(outputImage, from: inputImage.extent) else { return nil }

                    return UIImage(cgImage: cgImage)
                } catch {
                    print("Error processing image: \(error)")
                    return nil
                }
            } else {
                // Fallback for older iOS versions
                print("iOS 17+ required for this feature")
                return image
            }
        }.value
    }
}
