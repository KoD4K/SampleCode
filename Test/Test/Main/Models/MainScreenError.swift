enum MainScreenError: Error {
    case leftError
    case rightError
}

extension MainScreenError {

    var text: String {
        switch self {
        case .leftError:
            return "Problem with left side"
        case .rightError:
            return "Problem with right side"
        }
    }
}
