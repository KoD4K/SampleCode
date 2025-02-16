import Foundation

protocol Cancelable {
    func cancel()
}

extension URLSessionDataTask: Cancelable { }
extension URLSessionDownloadTask: Cancelable { }
