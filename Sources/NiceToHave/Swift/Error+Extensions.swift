import Foundation

public extension Error {
    /// Returns true when a URL request was explicitly cancelled, e.g. Alamofire's `explicitlyCancelled`.
    var isExplicitRequestCancellation: Bool {
        if self is CancellationError {
            return false
        }

        if let urlError = self as? URLError, urlError.code == .cancelled {
            return true
        }

        let nsError = self as NSError
        if nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
            return true
        }

        if nsError.localizedDescription == "Request explicitly cancelled." {
            return true
        }

        if let underlying = nsError.userInfo[NSUnderlyingErrorKey] as? Error,
           underlying.isExplicitRequestCancellation
        {
            return true
        }

        let description = String(describing: self)
        return description.contains("explicitlyCancelled")
    }
}
