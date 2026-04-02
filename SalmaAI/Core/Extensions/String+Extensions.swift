import Foundation

extension String {
    var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    var isValidPhone: Bool {
        let regex = "^[+]?[0-9]{7,15}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }

    func matches(regex pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(startIndex..., in: self)
        return regex.firstMatch(in: self, range: range) != nil
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isBlank: Bool {
        trimmed.isEmpty
    }
}
