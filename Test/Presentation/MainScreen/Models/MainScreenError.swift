enum MainScreenError: Error, Equatable {
    static func == (lhs: MainScreenError, rhs: MainScreenError) -> Bool {
        switch (lhs, rhs) {
        case (.baseRequest(_), .baseRequest(_)),
            (.graffitiRequest(_), .graffitiRequest(_)),
            (.noMoreData, .noMoreData),
            (.emptyText, .emptyText):
            return true
        default:
            return false
        }
    }

    case baseRequest(Error)
    case graffitiRequest(Error)
    case emptyText
    case noMoreData
}

extension MainScreenError {

    var text: String {
        switch self {
        case .baseRequest(let error):
            return "Problem with base request. Reason: \(error.localizedDescription)"
        case .graffitiRequest(let error):
            return "Problem with grafiti request. Reason: \(error.localizedDescription)"
        case .emptyText:
            return "Can't load any result without text request"
        case .noMoreData:
            return "No more data"
        }

    }
}
