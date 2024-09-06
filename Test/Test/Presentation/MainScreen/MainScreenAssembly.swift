import UIKit

final class MainScreenAssembly {

    func assembly() -> UIViewController {
        
        guard 
            let networkService: INetworkService = ServiceLocator.shared.resolve()
        else {
            return UIViewController()
        }
        let router = MainScreenRouter()
        let mainScreenService = MainScreenService(networkService: networkService)
        let presenter = MainScreenPresenter(router: router, service: mainScreenService)

        let viewController = MainScreenViewController(presenter: presenter)

        presenter.view = viewController
        router.transitionHandler = viewController

        return viewController
    }
}
