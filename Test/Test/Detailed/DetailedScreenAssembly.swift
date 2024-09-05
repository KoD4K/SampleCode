import UIKit

final class DetailedScreenAssembly {

    func assembly(withConfig config: DetailedScreenConfiguration) -> UIViewController {

        let presenter = DetailedScreenPresenter(config)
        let viewController = DetailedViewController(presenter: presenter)
        
        presenter.view = viewController

        return viewController
    }
}
