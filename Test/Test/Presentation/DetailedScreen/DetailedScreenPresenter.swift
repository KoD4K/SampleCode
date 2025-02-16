import UIKit

protocol IDetailedScreenPresenter {
    func onViewWillAppear()
    func onViewDidLayoutSubviews()
}

final class DetailedScreenPresenter {
    // Dependencies
    weak var view: IDetailedView?
    private let configuration: DetailedScreenConfiguration
    private let network: INetworkService

    // MARK: Init

    init(configuration: DetailedScreenConfiguration, network: INetworkService) {
        self.configuration = configuration
        self.network = network
    }

    // MARK: Private
    private func updateImageDependOn(index: Int, image: UIImage) {
        DispatchQueue.main.async {
            switch index {
            case 0:
                self.view?.update(leftImage: image)
            case 1:
                self.view?.update(rightImage: image)
            default: break
            }
        }
    }
}

// MARK: - IDetailedScreenPresenter

extension DetailedScreenPresenter: IDetailedScreenPresenter {

    func onViewWillAppear() {
        view?.update(imageCounts: configuration.imageUrls.count)
        
        for (index, url) in configuration.imageUrls.enumerated() {
            network.loadImage(url) { [weak self] result in
                switch result {
                case .success(let image):
                    self?.updateImageDependOn(index: index, image: image)
                    // TODO: - Handle failure
                case .failure(_):
                    break
                }
            }
        }
    }

    func onViewDidLayoutSubviews() {
        view?.update(startIndex: configuration.startIndex)
    }
}
