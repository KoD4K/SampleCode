import Foundation

final class GraffitiRequest: BaseRequest {

    override init(pageNumber: Int, searchString: String) {
        super.init(pageNumber: pageNumber, searchString: searchString + " graffiti")
    }
}
