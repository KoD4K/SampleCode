import Foundation

final class GraffitiRequest: BaseRequest {

    override init(pageNumber: Int, perPage: Int, searchString: String) {
        super.init(pageNumber: pageNumber, perPage: perPage, searchString: searchString + " graffiti")
    }
}
