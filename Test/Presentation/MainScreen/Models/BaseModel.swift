import Foundation

struct BaseModel: Decodable {
    let totalHits: Int
    let hits: [Hit]
}

struct Hit: Decodable {
    let webformatURL: URL
    let tags: String
}
