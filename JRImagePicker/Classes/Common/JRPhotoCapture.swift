//
//  JRPhotoCapture.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/18.
//

import Foundation
import AVFoundation

protocol JRPhotoCapture: class {
    /// 启动相机
    func start(with previewView: UIView, completion: @escaping ()->Void)
    /// 停止相机
    func stopCamera()
    /// 翻转相机
    func flipCamera(completion: @escaping () -> Void)
    /// 拍摄
    func shoot(completion: @escaping (Data) -> Void)
    /// 手动聚焦
    func focus(on point: CGPoint)
    /// 改变比例
    func updateLayer(frame: CGRect)
    /// 聚焦
    func zoom(began: Bool, scale: CGFloat)
    
    var hasFlash: Bool { get }
    /// 视频图层
    var videoLayer: AVCaptureVideoPreviewLayer! { get set }
    var device: AVCaptureDevice? { get }
    
    //-MARK: extension
    func configure()
    /// 采集会话
    var session: AVCaptureSession { get }
    /// 采集设备
    var deviceInput: AVCaptureDeviceInput? { get set }
    /// 输出
    var output: AVCaptureOutput { get }
    /// 会话创建标志
    var isCaptureSessionSetup: Bool { get set }
    /// 预览视图
    var previewView: UIView! { get set }
    /// 会话处理队列
    var sessionQueue: DispatchQueue { get }
    /// 是否设置预览视图
    var isPreviewSetup: Bool { get set }
    
    var initVideoZoomFactor: CGFloat { get set }
}

extension JRPhotoCapture {
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        let cameraPostion: AVCaptureDevice.Position = .back
        let aDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPostion)
        if let d = aDevice {
            deviceInput = try? AVCaptureDeviceInput(device: d)
        }
        if let videoInput = deviceInput {
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
                configure()
            }
        }
        session.commitConfiguration()
        isCaptureSessionSetup = true
    }
    
    func start(with previewView: UIView, completion: @escaping ()->Void) {
        self.previewView = previewView
        sessionQueue.async {[weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.isCaptureSessionSetup {
                strongSelf.setupCaptureSession()
            }
            strongSelf.startCamera(completion: {
                completion()
            })
            
        }
    }
    
    func startCamera(completion: @escaping ()->Void) {
        if !session.isRunning {
            sessionQueue.async { [weak self] in
                
                self?.session.sessionPreset = .photo
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                switch status {
                case .notDetermined, .restricted, .denied:
                    self?.session.stopRunning()
                case .authorized:
                    self?.session.startRunning()
                    completion()
                    self?.tryToSetupPreview()
                @unknown default:
                    fatalError()
                }
            }
        }
    }
    
    func stopCamera() {
        if session.isRunning {
            sessionQueue.async { [weak self] in
                self?.session.stopRunning()
            }
        }
    }
    
    func tryToSetupPreview() {
        if !isPreviewSetup {
            setupPreview()
            isPreviewSetup = true
        }
    }
    
    func setupPreview() {
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        DispatchQueue.main.async {
            self.videoLayer.frame = self.previewView.bounds
            self.videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewView.layer.addSublayer(self.videoLayer)
        }
    }
    
    
    func updateLayer(frame: CGRect) {
        guard let layer = videoLayer else {
            return
        }
        layer.frame = frame
    }
    
    func focus(on point: CGPoint) {
        setFocusPointOnDevice(device: device!, point: point)
    }
    
    private func setFocusPointOnDevice(device: AVCaptureDevice, point: CGPoint) {
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.autoFocus) {
                device.focusMode = .autoFocus
                device.focusPointOfInterest = point
            }
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
                device.exposurePointOfInterest = point
            }
            device.unlockForConfiguration()
        } catch _ {
            return
        }
    }
    
    func flipCamera(completion: @escaping () -> Void) {
        sessionQueue.async {[weak self] in
            self?.flip()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func flip() {
        session.resetInputs()
        guard let di = deviceInput else { return }
        let postion: AVCaptureDevice.Position = (di.device.position == .front) ? .back : .front
        deviceInput = try? AVCaptureDeviceInput(device: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: postion)!)
        guard let deviceInput = deviceInput else { return }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
    }
        
    func zoom(began: Bool, scale: CGFloat) {
        guard let device = device else {
            return
        }
        
        if began {
            initVideoZoomFactor = device.videoZoomFactor
            return
        }
        
        do {
            try device.lockForConfiguration()
            defer { device.unlockForConfiguration() }
            let minAvailableVideoZoomFactor: CGFloat = device.minAvailableVideoZoomFactor
            let maxAvailableVideoZoomFactor: CGFloat = device.activeFormat.videoMaxZoomFactor
            let desiredZoomFactor = initVideoZoomFactor * scale
            device.videoZoomFactor = max(minAvailableVideoZoomFactor,
                                         min(desiredZoomFactor, maxAvailableVideoZoomFactor))
        } catch let error {
           print("💩 \(error)")
        }
    }
}


extension AVCaptureSession {
    func resetInputs() {
        // remove all sesison inputs
        for i in inputs {
            removeInput(i)
        }
    }
}


enum JRFlashMode {
    case off
    case on
//    case auto
}

enum JRAspectRatioMode {
    case ratio1x1
    case ratio3x4
//    case ratio9x16
}
