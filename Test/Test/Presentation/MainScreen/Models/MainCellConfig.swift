import UIKit

struct MainCellConfig {
    let hits: [Hit?]
    let isSkeleton: Bool

    init(
        hits: [Hit?] = [],
        isSkeleton: Bool = false
    ) {
        self.hits = hits
        self.isSkeleton = isSkeleton
    }
}
