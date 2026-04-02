import XCTest
@testable import SalmaAI

final class FieldValidatorTests: XCTestCase {

    // MARK: - Required

    func test_requiredTextField_empty_returnsError() {
        let field = MockData.textField(isRequired: true)
        let error = FieldValidator.validate(field: field, value: "", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_requiredTextField_filled_returnsNil() {
        let field = MockData.textField(isRequired: true)
        let error = FieldValidator.validate(field: field, value: "Hello", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    func test_optionalTextField_empty_returnsNil() {
        let field = MockData.textField(isRequired: false)
        let error = FieldValidator.validate(field: field, value: "", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    func test_requiredCheckbox_unchecked_returnsError() {
        let field = MockData.checkboxField(isRequired: true)
        let error = FieldValidator.validate(field: field, value: "false", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_requiredCheckbox_checked_returnsNil() {
        let field = MockData.checkboxField(isRequired: true)
        let error = FieldValidator.validate(field: field, value: "true", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    func test_requiredMediaField_noCapturedImage_returnsError() {
        let field = MockData.photoField(isRequired: true)
        let error = FieldValidator.validate(field: field, value: "", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_requiredMediaField_hasCapturedImage_returnsNil() {
        let field = MockData.photoField(isRequired: true)
        let img = MockData.capturedImage()
        let error = FieldValidator.validate(field: field, value: "", capturedImage: img, language: .english)
        XCTAssertNil(error)
    }

    // MARK: - Text Validation

    func test_minLength_tooShort_returnsError() {
        let field = MockData.textField(minLength: 3)
        let error = FieldValidator.validate(field: field, value: "ab", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
        XCTAssertTrue(error!.contains("3"))
    }

    func test_minLength_exactLength_returnsNil() {
        let field = MockData.textField(minLength: 3)
        let error = FieldValidator.validate(field: field, value: "abc", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    func test_maxLength_tooLong_returnsError() {
        let field = MockData.textField(maxLength: 5)
        let error = FieldValidator.validate(field: field, value: "abcdef", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_regex_matching_returnsNil() {
        let field = MockData.textField(regex: "^[A-Za-z]+$")
        let error = FieldValidator.validate(field: field, value: "Hello", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    func test_regex_notMatching_returnsCustomError() {
        let field = MockData.textField(regex: "^[0-9]+$", regexError: "Numbers only")
        let error = FieldValidator.validate(field: field, value: "abc", capturedImage: nil, language: .english)
        XCTAssertEqual(error, "Numbers only")
    }

    func test_regex_notMatching_arabic_returnsArabicError() {
        let field = MockData.textField(regex: "^[0-9]+$", regexErrorAr: "أرقام فقط")
        let error = FieldValidator.validate(field: field, value: "abc", capturedImage: nil, language: .arabic)
        XCTAssertEqual(error, "أرقام فقط")
    }

    func test_invalidRegexPattern_returnsNil() {
        let field = MockData.textField(regex: "[invalid")
        let error = FieldValidator.validate(field: field, value: "test", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    // MARK: - Phone

    func test_phoneWithLetters_returnsError() {
        let field = MockData.phoneField()
        let error = FieldValidator.validate(field: field, value: "abc123", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_phoneTooShort_returnsError() {
        let field = MockData.phoneField()
        let error = FieldValidator.validate(field: field, value: "079", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_validPhone_returnsNil() {
        let field = MockData.phoneField()
        let error = FieldValidator.validate(field: field, value: "0791234567", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    // MARK: - Email

    func test_invalidEmail_returnsError() {
        let field = MockData.emailField()
        let error = FieldValidator.validate(field: field, value: "notanemail", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_validEmail_returnsNil() {
        let field = MockData.emailField()
        let error = FieldValidator.validate(field: field, value: "user@test.com", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    // MARK: - Date

    func test_mustBePast_futureDate_returnsError() {
        let field = MockData.dateField(mustBePast: true)
        let future = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"
        let error = FieldValidator.validate(field: field, value: fmt.string(from: future), capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_mustBePast_pastDate_returnsNil() {
        let field = MockData.dateField(mustBePast: true)
        let error = FieldValidator.validate(field: field, value: "1990-01-15", capturedImage: nil, language: .english)
        XCTAssertNil(error)
    }

    func test_mustBeFuture_pastDate_returnsError() {
        let field = MockData.dateField(mustBeFuture: true)
        let error = FieldValidator.validate(field: field, value: "2000-01-01", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_minDate_beforeMin_returnsError() {
        let field = MockData.dateField(minDate: "2020-01-01")
        let error = FieldValidator.validate(field: field, value: "2019-12-31", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    func test_maxDate_afterMax_returnsError() {
        let field = MockData.dateField(maxDate: "2020-12-31")
        let error = FieldValidator.validate(field: field, value: "2021-01-01", capturedImage: nil, language: .english)
        XCTAssertNotNil(error)
    }

    // MARK: - File Size

    func test_imageOverMaxSize_returnsError() {
        let field = MockData.photoField(maxFileSizeMB: 1)
        let bigImage = MockData.capturedImage(sizeKB: 2048) // 2MB
        let error = FieldValidator.validate(field: field, value: "", capturedImage: bigImage, language: .english)
        XCTAssertNotNil(error)
    }

    func test_imageUnderMaxSize_returnsNil() {
        let field = MockData.photoField(maxFileSizeMB: 5)
        let img = MockData.capturedImage(sizeKB: 500)
        let error = FieldValidator.validate(field: field, value: "", capturedImage: img, language: .english)
        XCTAssertNil(error)
    }
}
