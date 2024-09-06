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
        DispatchQueue.main.async {
            self.view?.update(withState: .loading)
        }

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

    func willDisplay(cell: MainScreenCell, withConfig config: MainCellConfig) {
        guard !config.isSkeleton else {
            DispatchQueue.main.async {
                cell.showSkeletons()
            }
            return
        }

        cell.hideSkeletons()

        let cellPresenter = MainScreenCellPresenter(output: self, hits: config.hits)

        cell.presenter = cellPresenter
        cellPresenter.view = cell

        for (index, hit) in config.hits.enumerated() {
            guard let hit else {
                cell.clear(index: index)
                return
            }

            let task = service.loadImage(forHit: hit) { [weak cellPresenter] image in
                cellPresenter?.imageLoaded(index: index, image: image)
            }
            cellPresenter.addTask(task)
        }
    }
}

extension MainScreenPresenter: IMainScreenCellOutput {

    func imageTapped(index: Int, imageUrls: [URL]) {
        let config = DetailedScreenConfiguration(
            imageUrls: imageUrls,
            startIndex: index
        )
        router.showDetailedScreen(withConfig: config)
    }
}
