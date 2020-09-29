//
//  JRDeviceOrientationHelper.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/28.
//
import UIKit
import CoreMotion

class JRDeviceOrientationHelper {
    static let shared = JRDeviceOrientationHelper()
    
    private let motionManager: CMMotionManager
    private let queue: OperationQueue
    
    typealias DeviceOrientationHandler = ((_ deviceOrientation: UIDeviceOrientation) -> Void)?
    private var deviceOrientationAction: DeviceOrientationHandler?
    
    public var currentDeviceOrientation: UIDeviceOrientation = .portrait
    
    private let motionLimit: Double = 0.6
    
    init() {
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 0.2
        
        queue = OperationQueue()
    }
    
    public func startDeviceOrientationNotifier(with handler: DeviceOrientationHandler) {
        self.deviceOrientationAction = handler
        
        motionManager.startAccelerometerUpdates(to: queue) { (data, error) in
            if let accelerometerData = data {
                var newDeviceOrientation: UIDeviceOrientation?
                
                if (accelerometerData.acceleration.x >= self.motionLimit) {
                    newDeviceOrientation = .landscapeRight
                }
                else if (accelerometerData.acceleration.x <= -self.motionLimit) {
                    newDeviceOrientation = .landscapeLeft
                }
                else if (accelerometerData.acceleration.y <= -self.motionLimit) {
                    newDeviceOrientation = .portrait
                }
                else if (accelerometerData.acceleration.y >= self.motionLimit) {
                    newDeviceOrientation = .portraitUpsideDown
                }
                else {
                    return
                }
                
                if let newDeviceOrientation = newDeviceOrientation, newDeviceOrientation != self.currentDeviceOrientation {
                    self.currentDeviceOrientation = newDeviceOrientation
                    if let deviceOrientationHandler = self.deviceOrientationAction {
                        DispatchQueue.main.async {
                            deviceOrientationHandler!(self.currentDeviceOrientation)
                        }
                    }
                }
            }
        }
    }
    
    public func stopDeviceOrientationNotifier() {
        motionManager.stopAccelerometerUpdates()
    }
}

