import AVFoundation
import UIKit

protocol CameraServiceProtocol {
    func requestCameraPermission() async -> Bool
    func checkCameraPermission() -> AVAuthorizationStatus
}
