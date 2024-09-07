import UIKit

protocol IMainScreenPresenter {
    /// Send message when user typed
    /// - Parameter text: user's text
    func onTextFieldDidChange(with text: String)

    func onWillDisplay(
        cell: MainScreenCell,
        withConfig config: MainCellConfig
    )

    func onWillDisplayLastCell()
}

final class MainScreenPresenter {

    // Dependencies
    weak var view: IMainScreenView?
    private let service: IMainScreenService
    private let router: IMainScreenRouter

    private var isLoading = false

    // MARK: - Init

    init(router: IMainScreenRouter, service: IMainScreenService) {
        self.router = router
        self.service = service
    }

    // MARK: Private

    private func handle(result: Result<MainScreenConfig, MainScreenError>) {
        isLoading = false
        DispatchQueue.main.async {
            switch result {
            case .success(let config):
                self.view?.update(withState: .loaded(config.cellConfigs))
            case .failure(let error):
                if error != .noMoreData {
                    self.view?.update(withState: .error(error))
                }
            }
        }
    }

    private func loadMoreDataIfAvailable() {
        service.loadMoreHits { [weak self] result in
            self?.handle(result: result)
        }
    }
}

// MARK: - IMainPresenter

extension MainScreenPresenter: IMainScreenPresenter {

    func onTextFieldDidChange(with text: String) {
        DispatchQueue.main.async {
            self.view?.update(withState: .loading)
        }

        service.loadHits(forText: text) { [weak self] result in
            self?.handle(result: result)
        }
    }

    func onWillDisplay(cell: MainScreenCell, withConfig config: MainCellConfig) {
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
                continue
            }

            let task = service.loadImage(forHit: hit) { [weak cellPresenter] image in
                cellPresenter?.imageLoaded(index: index, image: image)
            }
            cellPresenter.addTask(task)
        }
    }
    
    func onWillDisplayLastCell() {
        if !isLoading {
            loadMoreDataIfAvailable()
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
