import UIKit

final class ImageTagsView: UIView {

    enum Constants {
        static let spaceBetween: CGFloat = 10
        static let cornerRadius: CGFloat = 20
        static let imageHeight: CGFloat = 120
        static let tagsHeight: CGFloat = 20
    }

    private lazy var imageView = makeImageView()
    private lazy var tagsView = makeTagsView()

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ image: UIImage?, _ tags: String?, animation: Bool = false) {
        imageView.image = image?.withRoundedCorners(radius: Constants.cornerRadius)
        tagsView.text = tags
        
        if animation {
            imageView.alpha = 0
            UIView.animate(withDuration: 1) {
                self.imageView.alpha = 1
            }
        }
    }

    func showSkeletons() {
        imageView.showSkeleton()
        tagsView.showSkeleton()
    }

    func hideSkeletons() {
        imageView.hideSkeleton()
        tagsView.hideSkeleton()
    }

    // MARK: Private

    private func setupUI() {
        addSubview(imageView)
        addSubview(tagsView)

        imageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.spaceBetween).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.imageHeight).isActive = true

        tagsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tagsView.topAnchor.constraint(
            equalTo: imageView.bottomAnchor,
            constant: Constants.spaceBetween
        ).isActive = true
        tagsView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.tagsHeight).isActive = true
    }
}

// MARK: - UI builder

private extension ImageTagsView {

    func makeTagsView() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }
}
