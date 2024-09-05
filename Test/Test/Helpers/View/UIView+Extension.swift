import UIKit

public extension UIView {

    var isPreparedForAutoLayout: Bool { !translatesAutoresizingMaskIntoConstraints }

    @discardableResult
    func prepareForAutoLayout() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

public extension UIView {

    func pinToSuperviewEdges(edgeInsets: UIEdgeInsets) {
        guard let superview = superview else {
            return assertionFailure("Не обнаружена superview для \(description)")
        }
        checkAutoLayoutPreparing()

        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: edgeInsets.left).isActive = true
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: edgeInsets.right).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor, constant: edgeInsets.top).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: edgeInsets.bottom).isActive = true
    }

    func pinToSuperviewEdges(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) {
        pinToSuperviewEdges(edgeInsets: UIEdgeInsets(
            top: top,
            left: left,
            bottom: bottom,
            right: right
        ))
    }

    func pinToSuperviewEdges(oneInset: CGFloat) {
        pinToSuperviewEdges(
            top: oneInset,
            left: oneInset,
            bottom: -oneInset,
            right: -oneInset
        )
    }

    private func checkAutoLayoutPreparing() {
        if !self.isPreparedForAutoLayout {
            prepareForAutoLayout()
        }
    }
}
