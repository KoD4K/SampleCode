import UIKit

protocol IDetailedView: AnyObject {
    func update(leftImage: UIImage?)
    func update(rightImage: UIImage?)
    func update(_ startIndex: Int)
}

final class DetailedViewController: UIViewController {
    
    private enum Constants {
        static let screenWidth = UIScreen.main.bounds.size.width
        static let screenHeight = UIScreen.main.bounds.size.height
    }

    // Dependencies
    private let presenter: IDetailedScreenPresenter

    // UI
    private lazy var scrollView = makeScrollView()
    private lazy var leftImageView = makeImageView()
    private lazy var rightImageView = makeImageView()
    private lazy var pageControl = makePageControl()

    // MARK: - Init

    init(presenter: IDetailedScreenPresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter.onViewWillAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        presenter.onViewDidLayoutSubviews()
    }

    // MARK: - Private

    private func setupUI() {
        view.backgroundColor = .darkGray
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        scrollView.addSubview(leftImageView)
        scrollView.addSubview(rightImageView)

        scrollView.pinToSuperviewEdges()

        leftImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        leftImageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        leftImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        leftImageView.widthAnchor.constraint(equalToConstant: Constants.screenWidth).isActive = true
        leftImageView.heightAnchor.constraint(equalToConstant: Constants.screenHeight).isActive = true
        rightImageView.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor).isActive = true
        rightImageView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        rightImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        rightImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        rightImageView.widthAnchor.constraint(equalTo: leftImageView.widthAnchor).isActive = true
        rightImageView.heightAnchor.constraint(equalTo: leftImageView.heightAnchor).isActive = true

        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .down
        swipeGesture.addTarget(self, action: #selector(swipeDown))

        view.addGestureRecognizer(swipeGesture)
    }
}

// MARK: - UI builder

private extension DetailedViewController {

    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }

    func makePageControl() -> UIPageControl {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfPages = 2
        control.currentPage = 0
        return control
    }

    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        view.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        return view
    }
}

// MARK: - Private

private extension DetailedViewController {

    @objc 
    func swipeDown() {
        dismiss(animated: true)
    }
}

// MARK: - IDetailedView

extension DetailedViewController: IDetailedView {
    
    func update(leftImage: UIImage?) {
        leftImageView.image = leftImage
    }
    func update(rightImage: UIImage?) {
        rightImageView.image = rightImage
    }

    func update(_ startIndex: Int) {
        pageControl.currentPage = startIndex

        let contentOffsetPoint = CGPoint(x: Int(scrollView.frame.width) * startIndex, y: 0)

        scrollView.setContentOffset(contentOffsetPoint, animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension DetailedViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)

        pageControl.currentPage = currentPage
    }
}
