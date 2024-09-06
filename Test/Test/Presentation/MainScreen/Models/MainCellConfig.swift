import UIKit

struct MainCellConfig {
    let leftHit: Hit?
    let rightHit: Hit?
    let isSkeleton: Bool

    init(leftHit: Hit? = nil, rightHit: Hit? = nil, isSkeleton: Bool = false) {
        self.leftHit = leftHit
        self.rightHit = rightHit
        self.isSkeleton = isSkeleton
    }
}
