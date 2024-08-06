import Foundation

public extension Date {
    var tomorrow: Date? {
        Date.now.addingTimeInterval(3600 * 24 * 1).excludeTime
    }

    func date(afterDays: TimeInterval) -> Date? {
        Date.now.addingTimeInterval(3600 * 24 * afterDays).excludeTime
    }

    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    func date(afterHours: TimeInterval) -> Date? {
        Date.now.addingTimeInterval(3600 * afterHours).excludeTime
    }

    func hours(to date: Date) -> Int? {
        Calendar(identifier: .gregorian).dateComponents(
            [.hour],
            from: self,
            to: date
        ).hour
    }

    func days(to date: Date) -> Int? {
        Calendar(identifier: .gregorian).dateComponents(
            [.day],
            from: self,
            to: date
        ).day
    }

    func minutes(to date: Date) -> Int? {
        Calendar(identifier: .gregorian).dateComponents(
            [.minute],
            from: self,
            to: date
        ).minute
    }

    /**
     Removes time from date
     - returns a date without time
     */
    var excludeTime: Date? {
        Calendar(identifier: .gregorian).date(
            from: Calendar.current.dateComponents(
                [.year, .month, .day],
                from: self
            )
        )
    }

    /// A Dateformatter that ensures American dates only
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        // dateFormatter.locale = Locale(identifier: "se_SV")

        return dateFormatter
    }

    func string(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.replacingOccurrences(of: "XXX", with: adjustedMonthNameFormat)
        return dateFormatter.string(from: self)
    }

    var adjustedMonthNameFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: self).count > 5 ? "MMM" : "MMMM"
    }

    var dayLabel: String {
        if Calendar.current.isDateInToday(self) {
            return String(localized: "Today")
        } else if Calendar.current.isDateInTomorrow(self) {
            return String(localized: "Tomorrow")
        }
        return string(withFormat: "EEEE")
    }

    func dayLabelOr(format: String) -> String {
        if Calendar.current.isDateInToday(self) {
            return String(localized: "Today").lowercased()
        } else if Calendar.current.isDateInTomorrow(self) {
            return String(localized: "Tomorrow").lowercased()
        }
        return string(withFormat: format)
    }

    func timeWithDayLabelOr(format: String) -> String {
        if Calendar.current.isDateInToday(self) {
            return "\(String(localized: "Today")) \(string(withFormat: "HH:mm"))".lowercased()
        } else if Calendar.current.isDateInYesterday(self) {
            return "\(String(localized: "Yesterday")) \(string(withFormat: "HH:mm"))".lowercased()
        } else if Calendar.current.isDateInTomorrow(self) {
            return "\(String(localized: "Tomorrow")) \(string(withFormat: "HH:mm"))".lowercased()
        }
        return string(withFormat: format)
    }
}
