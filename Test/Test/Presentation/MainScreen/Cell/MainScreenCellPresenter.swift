import UIKit

protocol IMainScreenCellPresenter {
    func imageTapped(index: Int)
}

final class MainScreenCellPresenter {
    
    // Properties
    private var tasks: [Cancelable?] = []

    // Dependencies
    weak var view: IMainScreenCellView?
    private let output: IMainScreenCellOutput
    private let hits: [Hit?]

    init(output: IMainScreenCellOutput, hits: [Hit?]) {
        self.output = output

        self.hits = hits

        DispatchQueue.main.async {
            for (index, hit) in hits.enumerated() {
                self.view?.config(index: index, image: nil, text: hit?.tags)
            }
        }
    }

    deinit {
        tasks.compactMap { $0 }.forEach { $0.cancel() }
    }

    func imageLoaded(index: Int, image: UIImage?) {
        DispatchQueue.main.async {
            self.view?.config(index: index, image: image, text: self.hits[safe: index]??.tags)
        }
    }

    func addTask(_ task: Cancelable?) {
        tasks.append(task)
    }
}

extension MainScreenCellPresenter: IMainScreenCellPresenter {

    func imageTapped(index: Int) {
        let urls = hits.compactMap { $0 }.map { $0.webformatURL }

        output.imageTapped(index: index, imageUrls: urls)
    }
}

