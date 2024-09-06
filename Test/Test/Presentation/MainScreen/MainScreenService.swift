import UIKit

protocol IMainScreenService {
    func loadHits(
        forText text: String,
        completion: @escaping (Result<[MainCellConfig], MainScreenError>)->Void
    )
    func loadHits(
        forText text: String,
        forPage page: Int,
        completion: @escaping (Result<[MainCellConfig], MainScreenError>)->Void
    )
    func loadImage(forHit hit: Hit, completion: @escaping (UIImage?)->Void) -> Cancelable?
}

final class MainScreenService {
    // Dependencies
    private let networkService: INetworkService
    private let dispatchMain: DispatchQueue

    // Properties
    private var baseCancelable: Cancelable?
    private var graffitiCancelable: Cancelable?
    private var cache = NSCache<NSString, UIImage>()

    // MARK: - Init

    init(dispatchMain: DispatchQueue = DispatchQueue.main, networkService: INetworkService) {
        self.dispatchMain = dispatchMain
        self.networkService = networkService
    }
}

extension MainScreenService: IMainScreenService {

    func loadHits(
        forText text: String,
        completion: @escaping (Result<[MainCellConfig], MainScreenError>)->Void
    ) {
        loadHits(forText: text, forPage: 1, completion: completion)
    }
    
    func loadHits(
        forText text: String,
        forPage page: Int,
        completion: @escaping (Result<[MainCellConfig], MainScreenError>)->Void
    ) {
        baseCancelable?.cancel()
        graffitiCancelable?.cancel()

        let baseRequest = BaseRequest(pageNumber: page, searchString: text)
        let graffitiRequest = GraffitiRequest(pageNumber: page, searchString: text)

        var leftHits: [Hit] = []
        var rightHits: [Hit] = []
        var error: MainScreenError?

        let hitsDispatchGroup = DispatchGroup()
        hitsDispatchGroup.enter()
        baseCancelable = networkService.process(baseRequest) { result in
            defer {
                hitsDispatchGroup.leave()
            }
            switch result {
            case .success(let success):
                leftHits = success.hits
            case .failure(let failure):
                error = .leftError
            }
        }

        hitsDispatchGroup.enter()
        graffitiCancelable = networkService.process(graffitiRequest) { result in
            defer {
                hitsDispatchGroup.leave()
            }
            switch result {
            case .success(let success):
                rightHits = success.hits
            case .failure(let failure):
                error = .rightError
            }
        }

        hitsDispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            if let error {
                completion(.failure(error))
            } else {
                let configs = self.createConfigs(from: leftHits, and: rightHits)
                completion(.success(configs))
            }
        }
    }

    private func createConfigs(from leftHits: [Hit], and rightHits: [Hit]) -> [MainCellConfig] {
        let amout = max(leftHits.count, rightHits.count)

        var mainCellConfigs: [MainCellConfig] = []

        for i in 0..<amout {
            let config = MainCellConfig(
                leftHit: leftHits[safe: i],
                rightHit: rightHits[safe: i]
            )
            mainCellConfigs.append(config)
        }

        return mainCellConfigs
    }

    func loadImage(forHit hit: Hit, completion: @escaping (UIImage?)->Void) -> Cancelable? {
        networkService.loadImage(hit.webformatURL) { result in
            switch result {
            case .success(let success):
                completion(success)
            case .failure(let failure):
                completion(nil)
            }
        }
    }
}
