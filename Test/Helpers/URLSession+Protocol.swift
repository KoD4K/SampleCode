import Foundation

protocol IURLSession {

    func dataTask(
        with url: URL,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask

    func downloadTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (URL?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDownloadTask
}

extension URLSession: IURLSession { }

