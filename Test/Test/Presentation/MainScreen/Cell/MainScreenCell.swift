import UIKit

protocol IMainScreenCellOutput {
    func showDetailedScreen(withConfiguration config: DetailedScreenConfiguration)
}

protocol IMainScreenCellView: AnyObject {
    func config(withConfiguration config: MainScreenCell.Configuration)
    func clear(index: Int)
}

final class MainScreenCell: UITableViewCell {

    enum Constants {
        static let spaceBetween: CGFloat = 10
        static let horizontalStackViewTop: CGFloat = 10
    }

    static let reuseIdentifier = String(describing: MainScreenCell.self)

    // Dependencies
    var presenter: IMainScreenCellPresenter?

    // UI elements
    private lazy var horizontalStackView = makeStackView()
    private let leftImageTagsView = ImageTagsView()
    private let rightImageTagsView = ImageTagsView()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showSkeletons() {
        leftImageTagsView.showSkeletons()
        rightImageTagsView.showSkeletons()
    }

    func hideSkeletons() {
        leftImageTagsView.hideSkeletons()
        rightImageTagsView.hideSkeletons()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let leftConvertedPoint = leftImageTagsView.convert(point, from: self)

        if leftImageTagsView.bounds.contains(leftConvertedPoint) {
            return leftImageTagsView
        }

        let rightConvertedPoint = rightImageTagsView.convert(point, from: self)

        if rightImageTagsView.bounds.contains(rightConvertedPoint) {
            return rightImageTagsView
        }

        return super.hitTest(point, with: event)
    }
}

extension MainScreenCell: IMainScreenCellView {

    func config(withConfiguration config: Configuration) {
        switch config.index {
        case 0:
            leftImageTagsView.configure(config.image, config.text)
        case 1:
            rightImageTagsView.configure(config.image, config.text)
        default: break
        }
    }

    func clear(index: Int) {
        switch index {
        case 0:
            leftImageTagsView.configure(nil, nil)
        case 1:
            rightImageTagsView.configure(nil, nil)
        default: break
        }
    }
}

// MARK: - Private

private extension MainScreenCell {

    func setupUI() {
        addSubview(horizontalStackView)
        horizontalStackView.pinToSuperviewEdges(top: Constants.horizontalStackViewTop)
        horizontalStackView.addArrangedSubview(leftImageTagsView)
        horizontalStackView.addArrangedSubview(rightImageTagsView)

        selectionStyle = .none
    }

    func setupGesture() {
        let leftTapGesture = UITapGestureRecognizer()
        leftTapGesture.addTarget(self, action: #selector(leftTapAction))
        leftImageTagsView.isUserInteractionEnabled = true
        leftImageTagsView.addGestureRecognizer(leftTapGesture)

        let rightTapGesture = UITapGestureRecognizer()
        rightTapGesture.addTarget(self, action: #selector(rightTapAction))
        rightImageTagsView.isUserInteractionEnabled = true
        rightImageTagsView.addGestureRecognizer(rightTapGesture)
    }

    @objc
    private func leftTapAction() {
        presenter?.imageTapped(onSide: .left)
    }

    @objc
    private func rightTapAction() {
        presenter?.imageTapped(onSide: .right)
    }
}

// MARK: - UI Creator

private extension MainScreenCell {

    func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.spaceBetween
        return stackView
    }
}

// MARK: - Workspace

extension MainScreenCell {

    enum Side {
        case left
        case right
    }

    final class Configuration {
        let index: Int
        let image: UIImage?
        let text: String?

        init(index: Int, image: UIImage? = nil, text: String? = nil) {
            self.index = index
            self.image = image
            self.text = text
        }
    }
}
