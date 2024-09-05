//import Foundation
//
//protocol IMainDispatchQueue {
//    func performOnMain(_ action: @escaping ()->Void)
//}
//
//extension DispatchQueue: IMainDispatchQueue {
//    
//    func performOnMain(_ action: @escaping () -> Void) {
//        DispatchQueue.main.async {
//            action()
//        }
//    }
//}
//
//protocol IDispatchGroup {
//    func enter()
//    func leave()
//
//    func notify(queue: IMainDispatchQueue, _ action: @escaping ()-> Void)
//}
//
//extension DispatchGroup: IDispatchGroup {
//    func notify(queue: any IMainDispatchQueue, _ action: @escaping () -> Void) {
//        notify(queue: queue, execute: action)
//    }
//}
