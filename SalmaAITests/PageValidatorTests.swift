import XCTest
@testable import SalmaAI

final class PageValidatorTests: XCTestCase {

    func test_allRequiredFilled_returnsNoErrors() {
        let page = JourneyPage(
            id: "p1", title: "Test", titleAr: "تجربة", order: 1,
            fields: [MockData.textField(id: "f1")]
        )
        let errors = PageValidator.validatePage(
            page: page, fieldValues: ["f1": "Hello"],
            capturedImages: [:], allFieldValues: ["f1": "Hello"],
            language: .english
        )
        XCTAssertTrue(errors.isEmpty)
    }

    func test_missingRequiredField_returnsError() {
        let page = JourneyPage(
            id: "p1", title: "Test", titleAr: "تجربة", order: 1,
            fields: [MockData.textField(id: "f1")]
        )
        let errors = PageValidator.validatePage(
            page: page, fieldValues: [:],
            capturedImages: [:], allFieldValues: [:],
            language: .english
        )
        XCTAssertNotNil(errors["f1"])
    }

    func test_hiddenConditionalField_skipsValidation() {
        let field = PageField(
            id: "conditional", type: "Text", label: "Cond", labelAr: "شرطي",
            placeholder: nil, placeholderAr: nil, isRequired: true, order: 2,
            validationRules: ValidationRules(
                minLength: nil, maxLength: nil, regex: nil, regexError: nil, regexErrorAr: nil,
                mustBePast: nil, mustBeFuture: nil, minDate: nil, maxDate: nil,
                countryCode: nil, maxFileSizeMB: nil, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil, consentTextAr: nil, consentTextEn: nil,
                condition: FieldCondition(field: "trigger", operator: "equals", value: "show")
            ),
            options: nil
        )
        let page = JourneyPage(id: "p1", title: "T", titleAr: "ت", order: 1, fields: [field])

        // Condition not met — field hidden — should skip
        let errors = PageValidator.validatePage(
            page: page, fieldValues: [:],
            capturedImages: [:], allFieldValues: ["trigger": "hide"],
            language: .english
        )
        XCTAssertTrue(errors.isEmpty)
    }

    func test_visibleConditionalField_validates() {
        let field = PageField(
            id: "conditional", type: "Text", label: "Cond", labelAr: "شرطي",
            placeholder: nil, placeholderAr: nil, isRequired: true, order: 2,
            validationRules: ValidationRules(
                minLength: nil, maxLength: nil, regex: nil, regexError: nil, regexErrorAr: nil,
                mustBePast: nil, mustBeFuture: nil, minDate: nil, maxDate: nil,
                countryCode: nil, maxFileSizeMB: nil, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil, consentTextAr: nil, consentTextEn: nil,
                condition: FieldCondition(field: "trigger", operator: "equals", value: "show")
            ),
            options: nil
        )
        let page = JourneyPage(id: "p1", title: "T", titleAr: "ت", order: 1, fields: [field])

        // Condition met — field visible — should validate
        let errors = PageValidator.validatePage(
            page: page, fieldValues: [:],
            capturedImages: [:], allFieldValues: ["trigger": "show"],
            language: .english
        )
        XCTAssertNotNil(errors["conditional"])
    }

    func test_firstPageWithErrors_returnsCorrectIndex() {
        let journey = JourneyDetail(
            id: "j1", name: "J", description: nil, version: 1, status: "Published",
            pages: [
                JourneyPage(id: "p1", title: "P1", titleAr: "ص1", order: 1,
                            fields: [MockData.textField(id: "f1", isRequired: false)]),
                JourneyPage(id: "p2", title: "P2", titleAr: "ص2", order: 2,
                            fields: [MockData.textField(id: "f2", isRequired: true)])
            ],
            businessRules: []
        )

        let index = PageValidator.firstPageWithErrors(
            journey: journey, fieldValues: [:],
            capturedImages: [:], language: .english
        )
        XCTAssertEqual(index, 1) // Page 2 (index 1) has the required error
    }
}
