import UIKit

protocol IDetailedScreenPresenter {
    func onViewWillAppear()
    func onViewDidLayoutSubviews()
}

final class DetailedScreenPresenter {
    // Dependencies
    weak var view: IDetailedView?
    private var configuration: DetailedScreenConfiguration

    // MARK: - Init

    init(_ configuration: DetailedScreenConfiguration) {
        self.configuration = configuration
    }
}

// MARK: - IDetailedScreenPresenter

extension DetailedScreenPresenter: IDetailedScreenPresenter {

    func onViewWillAppear() {
        view?.update(configuration.leftSmallImage, configuration.rightSmallImage)
    }

    func onViewDidLayoutSubviews() {
        view?.update(configuration.startIndex)
    }
}
