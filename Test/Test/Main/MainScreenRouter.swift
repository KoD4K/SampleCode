import UIKit

protocol IMainScreenRouter {
    func showDetailedScreen(withConfig config: DetailedScreenConfiguration)
}

final class MainScreenRouter {
    weak var transitionHandler: UIViewController?
}

// MARK: - IMainScreenRouter

extension MainScreenRouter: IMainScreenRouter {

    func showDetailedScreen(withConfig config: DetailedScreenConfiguration) {
        let detailedScreen = DetailedScreenAssembly().assembly(withConfig: config)
        detailedScreen.modalPresentationStyle = .fullScreen
        detailedScreen.modalTransitionStyle = .coverVertical
        transitionHandler?.present(detailedScreen, animated: true)
    }
}
