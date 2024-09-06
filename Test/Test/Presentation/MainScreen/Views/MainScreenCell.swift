import UIKit

final class MainScreenCell: UITableViewCell {
    
    enum Constants {
        static let spaceBetween: CGFloat = 10
    }

    static let reuseIdentifier = String(describing: MainScreenCell.self)

    var leftLoadTask: Cancelable?
    var rightLoadTask: Cancelable?

    // UI elements
    private lazy var horizontalStackView = makeStackView()
    private let leftImageTagsView = ImageTagsView()
    private let rightImageTagsView = ImageTagsView()
    private var execution: ((UIImage?, UIImage?, Int)->Void)?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configLeftSide(_ image: UIImage?, _ tags: String) {
        leftImageTagsView.hideSkeleton()
        leftImageTagsView.configure(image, tags)
    }

    func configRightSide(_ image: UIImage?, _ tags: String) {
        rightImageTagsView.hideSkeleton()
        rightImageTagsView.configure(image, tags)
    }

    func showSkeletonForSubviews() {
        leftImageTagsView.showSkeleton()
        rightImageTagsView.showSkeleton()
    }

    func config(_ execution: @escaping (UIImage?, UIImage?, Int)->Void) {
        self.execution = execution

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
        execution?(leftImageTagsView.image, rightImageTagsView.image, 0)
    }

    @objc
    private func rightTapAction() {
        execution?(leftImageTagsView.image, rightImageTagsView.image, 1)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        clear()
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

// MARK: - Private

private extension MainScreenCell {

    func setupUI() {
        addSubview(horizontalStackView)
        horizontalStackView.pinToSuperviewEdges(top: 10)
        horizontalStackView.addArrangedSubview(leftImageTagsView)
        horizontalStackView.addArrangedSubview(rightImageTagsView)

        selectionStyle = .none
    }

    private func clear() {
        leftLoadTask?.cancel()
        rightLoadTask?.cancel()
        leftLoadTask = nil
        rightLoadTask = nil
        leftImageTagsView.configure(nil, .empty)
        rightImageTagsView.configure(nil, .empty)
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
