import UIKit

protocol IMainScreenService {
    func loadHits(
        forText text: String,
        completion: @escaping (Result<MainScreenConfig, MainScreenError>)->Void
    )
    func loadMoreHits(
        completion: @escaping (Result<MainScreenConfig, MainScreenError>)->Void
    )
    func loadImage(forHit hit: Hit, completion: @escaping (UIImage?)->Void) -> Cancelable?
}

final class MainScreenService {

    enum Constants {
        static let perPageCount = 20
    }

    // Dependencies
    private let networkService: INetworkService
    private let dispatchMain: DispatchQueue

    // Properties
    private var baseCancelable: Cancelable?
    private var graffitiCancelable: Cancelable?
    
    private var page = 0
    private var totalCounts = [0, 0]
    private var searchText = ""

    // MARK: - Init

    init(dispatchMain: DispatchQueue = DispatchQueue.main, networkService: INetworkService) {
        self.dispatchMain = dispatchMain
        self.networkService = networkService
    }

    // MARK: Private

    private func baseProcess(
        dispatchGroup: DispatchGroup,
        completion: @escaping (Result<BaseRequest.Model, NetworkError>)->Void
    ) {
        baseCancelable?.cancel()
        dispatchGroup.enter()

        let baseRequest = BaseRequest(pageNumber: page + 1, perPage: Constants.perPageCount, searchString: searchText)
        baseCancelable = networkService.process(baseRequest, completion: completion)
    }

    private func graffitiProcess(
        dispatchGroup: DispatchGroup,
        completion: @escaping (Result<BaseRequest.Model, NetworkError>)->Void
    ) {
        graffitiCancelable?.cancel()
        dispatchGroup.enter()

        let graffitiRequest = GraffitiRequest(pageNumber: page + 1, perPage: Constants.perPageCount, searchString: searchText)
        graffitiCancelable = networkService.process(graffitiRequest, completion: completion)
    }

    private func createConfigs(from leftHits: [Hit], and rightHits: [Hit]) -> [MainCellConfig] {
        let amout = max(leftHits.count, rightHits.count)

        var mainCellConfigs: [MainCellConfig] = []

        for i in 0..<amout {
            let config = MainCellConfig(hits: [leftHits[safe: i], rightHits[safe: i]])
            mainCellConfigs.append(config)
        }

        return mainCellConfigs
    }

    private func resetPaging() {
        page = 0
        totalCounts = [0, 0]
    }

    private var isBaseRequestHasMoreData: Bool {
        let baseTotalCount = totalCounts[0]
        if baseTotalCount == 0 { return true }
        return Int((Double(baseTotalCount) / Double(Constants.perPageCount)).rounded(.up)) == page + 1
    }
    private var isGraffitiRequestHasMoreData: Bool {
        let graffitiTotalCount = totalCounts[0]
        if graffitiTotalCount == 0 { return true }
        return Int((Double(graffitiTotalCount) / Double(Constants.perPageCount)).rounded(.up)) == page + 1
    }
}

extension MainScreenService: IMainScreenService {

    func loadHits(
        forText text: String,
        completion: @escaping (Result<MainScreenConfig, MainScreenError>)->Void
    ) {
        searchText = text

        resetPaging()
        loadMoreHits(completion: completion)
    }
    
    func loadMoreHits(
        completion: @escaping (Result<MainScreenConfig, MainScreenError>)->Void
    ) {
        if searchText.isEmpty {
            completion(.failure(.emptyText))
            return
        }

        var leftHits: [Hit] = []
        var rightHits: [Hit] = []
        var leftTotal = 0
        var rightTotal = 0
        var error: MainScreenError?

        let dispatchGroup = DispatchGroup()

        if isBaseRequestHasMoreData {
            baseProcess(dispatchGroup: dispatchGroup) { result in
                defer {
                    dispatchGroup.leave()
                }
                switch result {
                case .success(let success):
                    leftHits = success.hits
                    leftTotal = success.totalHits
                case .failure(let failure):
                    error = .baseRequest(failure)
                }
            }
        }

        if isGraffitiRequestHasMoreData {
            graffitiProcess(dispatchGroup: dispatchGroup) { result in
                defer {
                    dispatchGroup.leave()
                }
                switch result {
                case .success(let success):
                    rightHits = success.hits
                    rightTotal = success.totalHits
                case .failure(let failure):
                    error = .graffitiRequest(failure)
                }
            }
        }

        dispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            if let error {
                completion(.failure(error))
            } else if !self.isBaseRequestHasMoreData && !self.isGraffitiRequestHasMoreData {
                completion(.failure(.noMoreData))
            } else {
                self.page += 1
                let cellConfigs = self.createConfigs(from: leftHits, and: rightHits)
                let config = MainScreenConfig(cellConfigs: cellConfigs)
                self.totalCounts = [leftTotal, rightTotal]

                completion(.success(config))
            }
        }
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
