import UIKit

protocol IMainScreenCellOutput {
    func leftImageTapped(_ imageUrls:[URL])
    func rightImageTapped(_ imageUrls:[URL])
}

protocol IMainScreenCellView: AnyObject {
    func configLeftSide(_ image: UIImage?, _ tags: String?)
    func configRightSide(_ image: UIImage?, _ tags: String?)
    func clearLeftSide()
    func clearRightSide()
}

final class MainScreenCell: UITableViewCell {
    
    var presenter: IMainScreenCellPresenter?

    enum Constants {
        static let spaceBetween: CGFloat = 10
    }

    static let reuseIdentifier = String(describing: MainScreenCell.self)

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

    func configLeftSide(_ image: UIImage?, _ tags: String?) {
        leftImageTagsView.configure(image, tags)
    }

    func configRightSide(_ image: UIImage?, _ tags: String?) {
        rightImageTagsView.configure(image, tags)
    }

    func clearLeftSide() {
        configLeftSide(nil, nil)
    }
    func clearRightSide() {
        configRightSide(nil, nil)
    }
}

// MARK: - Private

private extension MainScreenCell {

    func setupUI() {
        addSubview(horizontalStackView)
        horizontalStackView.pinToSuperviewEdges(top: 10)
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
        presenter?.leftImageTapped()
    }

    @objc
    private func rightTapAction() {
        presenter?.rightImageTapped()
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
