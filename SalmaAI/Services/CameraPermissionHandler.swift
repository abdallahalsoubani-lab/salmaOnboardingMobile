import AVFoundation
import Photos
import SwiftUI

@MainActor
class CameraPermissionHandler: ObservableObject {
    @Published var cameraStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryStatus: PHAuthorizationStatus = .notDetermined

    init() {
        checkCurrentStatus()
    }

    func checkCurrentStatus() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }

    var isCameraAuthorized: Bool { cameraStatus == .authorized }
    var isPhotoLibraryAuthorized: Bool {
        photoLibraryStatus == .authorized || photoLibraryStatus == .limited
    }

    func requestCameraPermission() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        checkCurrentStatus()
        return granted
    }

    func requestPhotoLibraryPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        checkCurrentStatus()
        return status == .authorized || status == .limited
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
