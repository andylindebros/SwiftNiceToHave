#if os(iOS)
import UIKit
#endif

#if canImport(UIKit)
public extension UINavigationController {
    static func navBarHeight() -> CGFloat {
        let nVc = UINavigationController(rootViewController: UIViewController(nibName: nil, bundle: nil))
        let navBarHeight = nVc.navigationBar.frame.size.height
        return navBarHeight
    }
}
#endif
