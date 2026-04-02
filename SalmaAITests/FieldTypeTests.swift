import XCTest
@testable import SalmaAI

final class FieldTypeTests: XCTestCase {

    func test_isMediaField_forPhoto_true() {
        XCTAssertTrue(FieldType.photo.isMediaField)
    }

    func test_isMediaField_forText_false() {
        XCTAssertFalse(FieldType.text.isMediaField)
    }

    func test_isMediaField_forFileUpload_true() {
        XCTAssertTrue(FieldType.fileUpload.isMediaField)
    }

    func test_isMediaField_forSignature_true() {
        XCTAssertTrue(FieldType.signature.isMediaField)
    }

    func test_isCameraCapable_forSelfie_true() {
        XCTAssertTrue(FieldType.selfie.isCameraCapable)
    }

    func test_isCameraCapable_forFileUpload_false() {
        XCTAssertFalse(FieldType.fileUpload.isCameraCapable)
    }

    func test_isCamera_forIdScan_true() {
        XCTAssertTrue(FieldType.idScan.isCamera)
    }

    func test_isCamera_forCheckbox_false() {
        XCTAssertFalse(FieldType.checkbox.isCamera)
    }

    func test_isFilePicker_forFileUpload_true() {
        XCTAssertTrue(FieldType.fileUpload.isFilePicker)
    }

    func test_isFilePicker_forPhoto_false() {
        XCTAssertFalse(FieldType.photo.isFilePicker)
    }

    func test_captureSource_defaultBoth() {
        let source = FieldType.photo.captureSource(sourceType: nil)
        XCTAssertEqual(source, .cameraAndGallery)
    }

    func test_captureSource_cameraOnly() {
        let source = FieldType.photo.captureSource(sourceType: "camera")
        XCTAssertEqual(source, .cameraOnly)
    }

    func test_captureSource_galleryOnly() {
        let source = FieldType.photo.captureSource(sourceType: "gallery")
        XCTAssertEqual(source, .galleryOnly)
    }

    func test_captureSource_fileUploadAlwaysGallery() {
        let source = FieldType.fileUpload.captureSource(sourceType: "camera")
        XCTAssertEqual(source, .galleryOnly)
    }

    func test_allFieldTypes_haveDisplayNames() {
        for type in FieldType.allCases {
            XCTAssertFalse(type.displayNameEn.isEmpty)
            XCTAssertFalse(type.displayNameAr.isEmpty)
            XCTAssertFalse(type.iconName.isEmpty)
        }
    }
}
