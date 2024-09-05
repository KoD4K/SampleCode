import Foundation
import UIKit

enum NetworkError: Error {
    case noData
    case error(Error)
    case decode
}

protocol INetworkService {
    @discardableResult
    func process<Request, Model>(
        _ request: Request,
        completion: @escaping (Result<Model, NetworkError>) -> Void
    ) -> Cancelable? where Request: ModelRequest, Model == (Request.Model)

    @discardableResult
    func loadImage(
        _ imageUrl: URL,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void
    ) -> Cancelable?
}

final class NetworkService {

    private let urlSession: IURLSession

    // MARK: - Init

    init(urlSession: IURLSession) {
        self.urlSession = urlSession
    }
}

// MARK: - INetworkService

extension NetworkService: INetworkService {

    @discardableResult
    func process<Request, Model>(
        _ request: Request,
        completion: @escaping (Result<Model, NetworkError>) -> Void
    ) -> Cancelable? where Request: ModelRequest, Model == (Request.Model)  {
        guard let url = buildURL(from: request) else { return nil }

        let task = urlSession.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(.error(error)))
                return
            }
            guard let data else {
                completion(.failure(.noData))
                return
            }

            if let result = try? JSONDecoder().decode(Model.self, from: data) {
                completion(.success(result))
            } else {
                completion(.failure(.decode))
            }
        }

        task.resume()

        return task
    }

    @discardableResult
    func loadImage(
        _ imageUrl: URL,
        completion: @escaping (Result<UIImage, NetworkError>) -> Void
    ) -> Cancelable? {
        var urlRequest = URLRequest(url: imageUrl, cachePolicy: .returnCacheDataElseLoad)
        urlRequest.httpMethod = "GET"

        let task = urlSession.downloadTask(with: urlRequest) { localUrl, response, error in
            if let error {
                completion(.failure(.error(error)))
                return
            }
            if
              let localUrl,
              let data = try? Data(contentsOf: localUrl),
              let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(.decode))
            }
        }
        task.resume()

        return task
    }
}

// MARK: - Private

private extension NetworkService {

    func buildURL(from request: IRequest) -> URL? {
        let getParams = request.parameters
            .map{"\($0.key)=\($0.value)"}
            .joined(separator: "&")
        let urlString = "\(request.scheme)://\(request.host)/\(request.apiVersion)/?\(getParams)"

        return URL(string: urlString)
    }
}
