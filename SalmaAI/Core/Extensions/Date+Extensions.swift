import Foundation

extension Date {
    var isPast: Bool {
        self < Date()
    }

    var isFuture: Bool {
        self > Date()
    }

    func formatted(as format: String, locale: Locale = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }

    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }

    static func from(iso8601 string: String) -> Date? {
        ISO8601DateFormatter().date(from: string)
    }

    var age: Int {
        Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
    }
}
