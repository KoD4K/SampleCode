import Foundation

protocol IRequest {
    var scheme: String { get }
    var apiVersion: String { get }
    var host: String { get }
    var parameters: [String: Any] { get }
}

protocol ModelRequest: IRequest {
    associatedtype Model: Decodable
}

class BaseRequest: IRequest {

    static let key = "38738026-cb365c92113f40af7a864c24a"

    private let pageNumber: Int
    private let perPage: Int
    private let searchString: String

    init(pageNumber: Int, perPage: Int, searchString: String) {
        self.pageNumber = pageNumber
        self.perPage = perPage
        self.searchString = searchString
    }

    // MARK: - IRequest

    var scheme: String { "https" }
    var apiVersion: String { "api" }
    var host: String { "pixabay.com"}
    var parameters: [String: Any] {
        [
            "key": Self.key,
            "q": searchString,
            "page": pageNumber,
            "per_page": perPage
        ]
    }
}

extension BaseRequest: ModelRequest {
    typealias Model = BaseModel
}
