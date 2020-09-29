//
//  PostPhotoCapture.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/18.
//

import Foundation
import AVFoundation

class JRPostPhotoCapture: NSObject, JRPhotoCapture, AVCapturePhotoCaptureDelegate {
    
    let sessionQueue = DispatchQueue(label: "JRCameraVCSerialQueue", qos: .background)
    let session = AVCaptureSession()
    var deviceInput: AVCaptureDeviceInput?
    var device: AVCaptureDevice? { return deviceInput?.device }
    private let photoOutput = AVCapturePhotoOutput()
    var output: AVCaptureOutput { return photoOutput }
    var isCaptureSessionSetup: Bool = false
    var isPreviewSetup: Bool = false
    var previewView: UIView!
    var videoLayer: AVCaptureVideoPreviewLayer!
    var currentFlashMode: JRFlashMode = .off
    var currentAspectRatioMode: JRAspectRatioMode = .ratio1x1
    var hasFlash: Bool {
        guard let device = device else { return false }
        return device.hasFlash
    }
    var block: ((Data) -> Void)?
    var initVideoZoomFactor: CGFloat = 1.0
    
    // MARK: - Configuration
    
    private func newSettings() -> AVCapturePhotoSettings {
        var settings = AVCapturePhotoSettings()
        
        // Catpure Heif when available.
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        }
        
        
        // Catpure Highest Quality possible.
        settings.isHighResolutionPhotoEnabled = true
        
        // Set flash mode.
        if let deviceInput = deviceInput {
            if deviceInput.device.isFlashAvailable {
                switch currentFlashMode {
//                case .auto:
//                    settings.flashMode = .auto
                case .off:
                    settings.flashMode = .off
                case .on:
                    settings.flashMode = .on
                }
            }
        }
        return settings
    }
    
    func configure() {
        photoOutput.isHighResolutionCaptureEnabled = true
        
        // Improve capture time by preparing output with the desired settings.
        photoOutput.setPreparedPhotoSettingsArray([newSettings()], completionHandler: nil)
    }
    
    // MARK: - Flash
    
    func tryToggleFlash() {
        // if device.hasFlash device.isFlashAvailable //TODO test these
        switch currentFlashMode {
//        case .auto:
//            currentFlashMode = .on
        case .on:
            currentFlashMode = .off
        case .off:
            currentFlashMode = .on
//            currentFlashMode = .auto
        }
    }
    
    // MARK: - Ratio
    
    func tryToggleAspectRatio(frame: CGRect) {
        switch currentAspectRatioMode {
        case .ratio1x1:
            currentAspectRatioMode = .ratio3x4
            print("size === \(videoLayer.preferredFrameSize())")
        case .ratio3x4:
            currentAspectRatioMode = .ratio1x1
            print("size === \(videoLayer.preferredFrameSize())")
//            currentAspectRatioMode = .ratio9x16
//        case .ratio9x16:
//            currentAspectRatioMode = .ratio1x1
        }
        updateLayer(frame: frame)
    }
    
    // MARK: - Shoot

    func shoot(completion: @escaping (Data) -> Void) {
        block = completion
    
        // Set current device orientation
//        setCurrentOrienation()
        
        let settings = newSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        block?(data)
    }
        
}
