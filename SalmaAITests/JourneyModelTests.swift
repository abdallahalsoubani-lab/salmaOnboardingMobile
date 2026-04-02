import XCTest
@testable import SalmaAI

final class JourneyModelTests: XCTestCase {

    func test_decodeJourneyJSON_parsesCorrectly() throws {
        let data = MockData.sampleJourneyJSON()
        let journey = try JSONDecoder().decode(JourneyDetail.self, from: data)
        XCTAssertEqual(journey.id, "test-journey-id")
        XCTAssertEqual(journey.name, "Test Journey")
        XCTAssertEqual(journey.version, 1)
        XCTAssertEqual(journey.pages.count, 1)
        XCTAssertEqual(journey.pages.first?.fields.count, 2)
    }

    func test_decodeFieldTypes_allTypesRecognized() {
        for fieldType in FieldType.allCases {
            XCTAssertNotNil(FieldType(rawValue: fieldType.rawValue), "FieldType \(fieldType.rawValue) not recognized")
        }
    }

    func test_decodeValidationRules_parsesMinMax() throws {
        let data = MockData.sampleJourneyJSON()
        let journey = try JSONDecoder().decode(JourneyDetail.self, from: data)
        let nameField = journey.pages.first?.fields.first
        XCTAssertEqual(nameField?.validationRules?.minLength, 3)
        XCTAssertEqual(nameField?.validationRules?.maxLength, 100)
    }

    func test_decodeBusinessRules_parsesCondition() throws {
        let data = MockData.sampleJourneyJSON()
        let journey = try JSONDecoder().decode(JourneyDetail.self, from: data)
        XCTAssertEqual(journey.businessRules.count, 1)
        XCTAssertEqual(journey.businessRules.first?.ruleName, "Age Gate")
        XCTAssertEqual(journey.businessRules.first?.condition.field, "dob")
        XCTAssertEqual(journey.businessRules.first?.condition.value?.intValue, 18)
    }

    func test_anyCodableValue_decodesInt() throws {
        let json = #"{"field":"x","operator":"lt","value":18}"#.data(using: .utf8)!
        let condition = try JSONDecoder().decode(RuleCondition.self, from: json)
        XCTAssertEqual(condition.value?.intValue, 18)
    }

    func test_anyCodableValue_decodesString() throws {
        let json = #"{"field":"x","operator":"eq","value":"test"}"#.data(using: .utf8)!
        let condition = try JSONDecoder().decode(RuleCondition.self, from: json)
        XCTAssertEqual(condition.value?.stringValue, "test")
    }

    func test_anyCodableValue_decodesBool() throws {
        let json = #"{"field":"x","operator":"eq","value":true}"#.data(using: .utf8)!
        let condition = try JSONDecoder().decode(RuleCondition.self, from: json)
        XCTAssertEqual(condition.value?.boolValue, true)
    }
}
