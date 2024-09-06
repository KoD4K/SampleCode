import UIKit

protocol IMainScreenCellPresenter {
    func leftImageTapped()
    func rightImageTapped()
}

final class MainScreenCellPresenter {
    
    // Properties
    var leftTask: Cancelable?
    var rightTask: Cancelable?

    // Dependencies
    weak var view: IMainScreenCellView?
    private let output: IMainScreenCellOutput
    private let leftHit: Hit?
    private let rightHit: Hit?

    init(output: IMainScreenCellOutput, leftHit: Hit?, rightHit: Hit?) {
        self.output = output
        self.leftHit = leftHit
        self.rightHit = rightHit

        updateLeft()
        updateRight()
    }

    deinit {
        leftTask?.cancel()
        rightTask?.cancel()
    }

    func leftImageLoaded(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.view?.configLeftSide(image, self.leftHit?.tags)
        }
    }
    func rightImageLoaded(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.view?.configRightSide(image, self.rightHit?.tags)
        }
    }
}

private extension MainScreenCellPresenter {
    func updateLeft() {
        DispatchQueue.main.async {
            self.view?.configLeftSide(nil, self.leftHit?.tags)
        }
    }
    func updateRight() {
        DispatchQueue.main.async {
            self.view?.configRightSide(nil, self.rightHit?.tags)
        }
    }
}

extension MainScreenCellPresenter: IMainScreenCellPresenter {

    func leftImageTapped() {
        guard let leftHit, let rightHit else { return }

        output.leftImageTapped([leftHit.webformatURL, rightHit.webformatURL])
    }

    func rightImageTapped() {
        guard let leftHit, let rightHit else { return }

        output.rightImageTapped([leftHit.webformatURL, rightHit.webformatURL])
    }
}

