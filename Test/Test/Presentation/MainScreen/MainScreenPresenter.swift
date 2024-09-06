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
        let cellPresenter = MainScreenCellPresenter(
            output: self,
            leftHit: config.leftHit,
            rightHit: config.rightHit
        )

        if let leftHit = config.leftHit {
            cellPresenter.leftTask = service.loadImage(forHit: leftHit) { [weak cellPresenter] image in
                cellPresenter?.leftImageLoaded(image)
            }
        } else {
            DispatchQueue.main.async {
                cellPresenter.view?.clearLeftSide()
            }
        }
        if let rightHit = config.rightHit {
            cellPresenter.rightTask = service.loadImage(forHit: rightHit) { [weak cellPresenter] image in
                cellPresenter?.rightImageLoaded(image)
            }
        } else {
            DispatchQueue.main.async {
                cellPresenter.view?.clearRightSide()
            }
        }

        cell.presenter = cellPresenter
        cellPresenter.view = cell
    }
}

extension MainScreenPresenter: IMainScreenCellOutput {

    func leftImageTapped(_ imageUrls:[URL]) {
        let config = DetailedScreenConfiguration(
            imageUrls: imageUrls,
            startIndex: 0
        )
        router.showDetailedScreen(withConfig: config)
    }
    
    func rightImageTapped(_ imageUrls:[URL]) {
        let config = DetailedScreenConfiguration(
            imageUrls: imageUrls,
            startIndex: 1
        )
        router.showDetailedScreen(withConfig: config)
    }
}
