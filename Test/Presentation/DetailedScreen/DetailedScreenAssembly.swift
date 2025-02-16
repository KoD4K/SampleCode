import UIKit

final class DetailedScreenAssembly {

    func assembly(withConfig config: DetailedScreenConfiguration) -> UIViewController {

        guard
            let networkService: INetworkService = ServiceLocator.shared.resolve()
        else {
            return UIViewController()
        }

        let presenter = DetailedScreenPresenter(configuration: config, network: networkService)
        let viewController = DetailedViewController(presenter: presenter)
        
        presenter.view = viewController

        return viewController
    }
}
