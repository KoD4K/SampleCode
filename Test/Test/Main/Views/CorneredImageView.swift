import UIKit

final class CorneredImageView: UIImageView {
    static let cornerRadius: CGFloat = 20.0

    override func draw(_ rect: CGRect) {
        let borderPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: CorneredImageView.cornerRadius
        )
        UIColor.white.set()
        borderPath.fill()
    }
}
