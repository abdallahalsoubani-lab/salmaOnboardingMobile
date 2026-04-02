import Foundation
@testable import SalmaAI

struct MockData {
    static func textField(
        id: String = "test_field",
        isRequired: Bool = true,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        regex: String? = nil,
        regexError: String? = nil,
        regexErrorAr: String? = nil
    ) -> PageField {
        PageField(
            id: id, type: "Text", label: "Test Field", labelAr: "حقل تجريبي",
            placeholder: "Enter value", placeholderAr: "أدخل القيمة",
            isRequired: isRequired, order: 1,
            validationRules: ValidationRules(
                minLength: minLength, maxLength: maxLength,
                regex: regex, regexError: regexError, regexErrorAr: regexErrorAr,
                mustBePast: nil, mustBeFuture: nil, minDate: nil, maxDate: nil,
                countryCode: nil, maxFileSizeMB: nil, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil,
                consentTextAr: nil, consentTextEn: nil, condition: nil
            ),
            options: nil
        )
    }

    static func phoneField(id: String = "phone", isRequired: Bool = true, countryCode: String? = "+962", regex: String? = nil) -> PageField {
        PageField(
            id: id, type: "Phone", label: "Phone", labelAr: "هاتف",
            placeholder: nil, placeholderAr: nil, isRequired: isRequired, order: 1,
            validationRules: ValidationRules(
                minLength: nil, maxLength: nil, regex: regex, regexError: nil, regexErrorAr: nil,
                mustBePast: nil, mustBeFuture: nil, minDate: nil, maxDate: nil,
                countryCode: countryCode, maxFileSizeMB: nil, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil, consentTextAr: nil, consentTextEn: nil, condition: nil
            ),
            options: nil
        )
    }

    static func emailField(id: String = "email", isRequired: Bool = true) -> PageField {
        PageField(
            id: id, type: "Email", label: "Email", labelAr: "بريد إلكتروني",
            placeholder: nil, placeholderAr: nil, isRequired: isRequired, order: 1,
            validationRules: nil, options: nil
        )
    }

    static func dateField(id: String = "dob", isRequired: Bool = true, mustBePast: Bool = false, mustBeFuture: Bool = false, minDate: String? = nil, maxDate: String? = nil) -> PageField {
        PageField(
            id: id, type: "Date", label: "Date", labelAr: "تاريخ",
            placeholder: nil, placeholderAr: nil, isRequired: isRequired, order: 1,
            validationRules: ValidationRules(
                minLength: nil, maxLength: nil, regex: nil, regexError: nil, regexErrorAr: nil,
                mustBePast: mustBePast, mustBeFuture: mustBeFuture, minDate: minDate, maxDate: maxDate,
                countryCode: nil, maxFileSizeMB: nil, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil, consentTextAr: nil, consentTextEn: nil, condition: nil
            ),
            options: nil
        )
    }

    static func checkboxField(id: String = "consent", isRequired: Bool = true) -> PageField {
        PageField(
            id: id, type: "Checkbox", label: "I agree", labelAr: "أوافق",
            placeholder: nil, placeholderAr: nil, isRequired: isRequired, order: 1,
            validationRules: ValidationRules(
                minLength: nil, maxLength: nil, regex: nil, regexError: nil, regexErrorAr: nil,
                mustBePast: nil, mustBeFuture: nil, minDate: nil, maxDate: nil,
                countryCode: nil, maxFileSizeMB: nil, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil,
                consentTextAr: "أوافق على الشروط", consentTextEn: "I agree to terms", condition: nil
            ),
            options: nil
        )
    }

    static func photoField(id: String = "photo", isRequired: Bool = true, maxFileSizeMB: Int? = nil) -> PageField {
        PageField(
            id: id, type: "Photo", label: "Photo", labelAr: "صورة",
            placeholder: nil, placeholderAr: nil, isRequired: isRequired, order: 1,
            validationRules: ValidationRules(
                minLength: nil, maxLength: nil, regex: nil, regexError: nil, regexErrorAr: nil,
                mustBePast: nil, mustBeFuture: nil, minDate: nil, maxDate: nil,
                countryCode: nil, maxFileSizeMB: maxFileSizeMB, acceptedFormats: nil,
                sourceType: nil, allowMultiple: nil, consentTextAr: nil, consentTextEn: nil, condition: nil
            ),
            options: nil
        )
    }

    static func capturedImage(fieldId: String = "test", sizeKB: Int = 500) -> CapturedImage {
        CapturedImage(fieldId: fieldId, imageData: Data(count: sizeKB * 1024), type: .photo)
    }

    static func sampleJourneyJSON() -> Data {
        """
        {
            "id": "test-journey-id",
            "name": "Test Journey",
            "description": "Test",
            "version": 1,
            "status": "Published",
            "pages": [
                {
                    "id": "page-1",
                    "title": "Personal Info",
                    "titleAr": "المعلومات الشخصية",
                    "order": 1,
                    "fields": [
                        {
                            "id": "field-name",
                            "type": "Text",
                            "label": "Full Name",
                            "labelAr": "الاسم الكامل",
                            "placeholder": "Enter name",
                            "placeholderAr": "أدخل الاسم",
                            "isRequired": true,
                            "order": 1,
                            "validationRules": { "minLength": 3, "maxLength": 100 },
                            "options": null
                        },
                        {
                            "id": "field-email",
                            "type": "Email",
                            "label": "Email",
                            "labelAr": "بريد إلكتروني",
                            "isRequired": false,
                            "order": 2,
                            "validationRules": null,
                            "options": null
                        }
                    ]
                }
            ],
            "businessRules": [
                {
                    "id": "rule-1",
                    "ruleName": "Age Gate",
                    "ruleType": "Reject",
                    "condition": { "field": "dob", "operator": "age_less_than", "value": 18 },
                    "action": { "message": "Must be 18+", "messageAr": "يجب أن يكون العمر 18+" },
                    "isActive": true
                }
            ]
        }
        """.data(using: .utf8)!
    }
}
