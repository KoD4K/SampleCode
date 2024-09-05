import UIKit

extension UIView {

    private static let shimmerAnimationKey = "shimmerAnimation"

    var skeletonLayerName: String { "skeletonLayerName" }
    var skeletonGradientName: String { "skeletonGradientName" }

    func showSkeleton() {

        let backgroundColor = UIColor(red: 210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).cgColor
        let highlightColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor

        let skeletonLayer = CALayer()
        skeletonLayer.backgroundColor = backgroundColor
        skeletonLayer.name = skeletonLayerName
        skeletonLayer.anchorPoint = .zero
        skeletonLayer.frame.size = frame.size

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [backgroundColor, highlightColor, backgroundColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = bounds
        gradientLayer.name = skeletonGradientName

        layer.mask = skeletonLayer
        layer.addSublayer(skeletonLayer)
        layer.addSublayer(gradientLayer)
        layer.cornerRadius = 10
        clipsToBounds = true
        let widht = UIScreen.main.bounds.width

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.duration = 3
        animation.fromValue = -widht
        animation.toValue = widht
        animation.repeatCount = .infinity
        animation.autoreverses = false
        animation.fillMode = CAMediaTimingFillMode.forwards

        gradientLayer.add(animation, forKey: "gradientLayerShimmerAnimation")
    }

    func hideSkeleton() {
        layer.sublayers?.removeAll {
            $0.name == skeletonLayerName || $0.name == skeletonGradientName
        }
    }
}

