import UIKit

protocol IMainScreenPresenter {
    /// Send message when user typed
    /// - Parameter text: user's text
    func onTextFieldDidChange(with text: String)

    func willDisplay(
        cell: MainScreenCell,
        withConfig config: MainCellConfig
    )
}

final class MainScreenPresenter {

    // Dependencies
    weak var view: IMainScreenView?
    private let service: IMainScreenService
    private let router: IMainScreenRouter

    // Properties
    private var currentPage = 1
    private var totalPages = 0

    // MARK: - Init

    init(router: IMainScreenRouter, service: IMainScreenService) {
        self.router = router
        self.service = service
    }
}

// MARK: - IMainPresenter

extension MainScreenPresenter: IMainScreenPresenter {

    func onTextFieldDidChange(with text: String) {
        service.loadHits(forText: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.view?.update(withState: .loaded(data))
                case .failure(let error):
                    self?.view?.update(withState: .error(error))
                }
            }
        }
    }

    func willDisplay(
        cell: MainScreenCell,
        withConfig config: MainCellConfig
    ) {
        DispatchQueue.main.async {
            cell.showSkeletonForSubviews()
        }

        if let leftHit = config.leftHit {
            cell.leftLoadTask = service.loadImage(forHit: leftHit) { [weak cell] image in
                DispatchQueue.main.async {
                    cell?.configLeftSide(image, leftHit.tags)
                }
            }
        } else {
            DispatchQueue.main.async {
                cell.configLeftSide(nil, .empty)
            }
        }
        if let rightHit = config.rightHit {
            cell.rightLoadTask = service.loadImage(forHit: rightHit) { [weak cell] image in
                DispatchQueue.main.async {
                    cell?.configRightSide(image, rightHit.tags)
                }
            }
        } else {
            DispatchQueue.main.async {
                cell.configRightSide(nil, .empty)
            }
        }

        cell.config { [weak self] leftImage, rightImage, startIndex in
            let config = DetailedScreenConfiguration(
                leftSmallImage: leftImage,
                rightSmallImage: rightImage,
                leftLargeImageURL: nil,
                rightLargeImageURL: nil,
                startIndex: startIndex
            )
            self?.router.showDetailedScreen(withConfig: config)
        }
    }
}

