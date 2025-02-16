import UIKit

protocol IMainScreenCellPresenter {
    func imageTapped(onSide side: MainScreenCell.Side)
}

final class MainScreenCellPresenter {

    enum Constants {
        static let cornerRadius: CGFloat = 20
    }

    // Properties
    private var tasks: [Cancelable?] = []

    // Dependencies
    weak var view: IMainScreenCellView?
    private let output: IMainScreenCellOutput
    private let hits: [Hit?]

    init(output: IMainScreenCellOutput, hits: [Hit?]) {
        self.output = output
        self.hits = hits

        for (index, hit) in hits.enumerated() {
            let tags = hit?.tags
            let config = MainScreenCell.Configuration(index: index, text: tags)

            DispatchQueue.main.async {
                self.view?.config(withConfiguration: config)
            }
        }
    }

    deinit {
        tasks.compactMap { $0 }.forEach { $0.cancel() }
    }

    func imageLoaded(index: Int, image: UIImage?) {
        let roundedImage = image?.withRoundedCorners(radius: Constants.cornerRadius)
        let tagsString = hits[safe: index]??.tags
        let cellConfig = MainScreenCell.Configuration(index: index, image: roundedImage, text: tagsString)
        DispatchQueue.main.async {
            self.view?.config(withConfiguration: cellConfig)
        }
    }

    func addTask(_ task: Cancelable?) {
        tasks.append(task)
    }
}

extension MainScreenCellPresenter: IMainScreenCellPresenter {

    func imageTapped(onSide side: MainScreenCell.Side) {
        let urls = hits.compactMap { $0 }.map { $0.webformatURL }
        let startIndex = side == .left ? 0 : 1
        let config = DetailedScreenConfiguration(imageUrls: urls, startIndex: startIndex)

        output.showDetailedScreen(withConfiguration: config)
    }
}
