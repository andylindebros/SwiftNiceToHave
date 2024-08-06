import Foundation

public struct DateLimiter {
    /**
     Checks a key in UserDefaults if it is older than desired expire date.
     - parameter userDefaults: The storage to store the keyValue in. Default is the UserDefaults singleton
     */
    public init(userDefaults: UserDefaultsProvider = UserDefaults.standard) {
        self.userDefaults = userDefaults
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Self.dateFormat
    }

    public static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    private let userDefaults: UserDefaultsProvider
    private let dateFormatter: DateFormatter

    /**
     Checks the key if it has expired.
     Note: The key should be consider as valid if no date limit was found
     - parameter key: The key to look up the date with
     - parameter limit: the amount of minutes until the key expires
     - returns Boolean: if the key has expired or not
     */
    public func isDate(forKey key: String, olderThan limit: Int) -> Bool {
        guard
            let dateString = userDefaults.string(forKey: key),
            let date = dateFormatter.date(from: dateString)
        else {
            return true
        }
        let minutesFromNow = date.minutes(to: Date())

        let result = minutesFromNow ?? limit >= limit
        return result
    }

    /**
     Updates the comparison date to use next time it needs to be compared.
     - parameter date: The date to compare with.
     - parameter key: The key to look up the date with
     */
    public func set(_ date: Date, forKey key: String) {
        let string = dateFormatter.string(from: date)
        userDefaults.set(string, forKey: key)
    }
}
