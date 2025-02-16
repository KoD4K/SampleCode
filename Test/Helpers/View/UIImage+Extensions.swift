import UIKit

extension UIImage {

    func withRoundedCorners(radius: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { _ in
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            path.addClip()
            draw(in: rect)
        }
    }
}

