//
//  MTImageCropController.swift
//  23
//
//  Created by 焦瑞洁 on 2020/5/27.
//  Copyright © 2020 ddcx. All rights reserved.
//

import UIKit

public class MTImageCropController: UIViewController {
    
    public var didFinishCropping: ((UIImage) -> Void)?
    
    public override var prefersStatusBarHidden: Bool { return true }
    
    private let originalImage: UIImage? = nil
    private let pinchGR = UIPinchGestureRecognizer()
    private let panGR = UIPanGestureRecognizer()
    
    public var original: MTImagePickerModel? {
        didSet{
            original?.getImageAsync(complete: { [weak self](image) in
                if let originalImage = image {
                    self?.v.setConfig(image: originalImage)
                }
            })
        }
    }
        
    lazy var v: JYPCropView = {
       
        let cropView =  Bundle(for: MTImageCropController.self).loadNibNamed("JYPImagePickerViews", owner: nil, options: nil)?.first as! JYPCropView
        return cropView
    }()
    
   public class var instance:MTImageCropController {
          get {
              let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTImagePickerController.self))
              let vc = storyboard.instantiateViewController(withIdentifier: "MTImageCropController") as! MTImageCropController
              return vc
          }
      }
    
    
   public override func loadView() { view = v }
    
   public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
   public override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupGestureRecognizers()
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupToolbar() {
        v.cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        v.selectBtn.addTarget(self, action: #selector(done), for: .touchUpInside)
    }
    
    func setupGestureRecognizers() {
        // Pinch Gesture
        pinchGR.addTarget(self, action: #selector(pinch(_:)))
        pinchGR.delegate = self
        v.imageView.addGestureRecognizer(pinchGR)
        
        // Pan Gesture
        panGR.addTarget(self, action: #selector(pan(_:)))
        panGR.delegate = self
        v.imageView.addGestureRecognizer(panGR)
    }
    
    @objc
    func cancel() {
        dismiss(animated: true, completion: nil)
        //        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func done() {
        guard let image = v.imageView.image else {
            return
        }
        
        let xCrop = v.cropArea.frame.minX - v.imageView.frame.minX
        let yCrop = v.cropArea.frame.minY - v.imageView.frame.minY
        let widthCrop = v.cropArea.frame.width
        let heightCrop = v.cropArea.frame.height
        let scaleRatio = image.size.width / v.imageView.frame.width
        let scaledCropRect = CGRect(x: xCrop * scaleRatio,
                                    y: yCrop * scaleRatio,
                                    width: widthCrop * scaleRatio,
                                    height: heightCrop * scaleRatio)
        
        if let cgImage = image.toCIImage()?.toCGImage(),
            let imageRef = cgImage.cropping(to: scaledCropRect) {
            let croppedImage = UIImage(cgImage: imageRef)
            
            original?.croppedImage = croppedImage
            didFinishCropping?(croppedImage)
        }
    }
}

extension UIImage {
    func toCIImage() -> CIImage? {
        return self.ciImage ?? CIImage(cgImage: self.cgImage!)
    }
}

extension CIImage {
    func toCGImage() -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return cgImage
        }
        return nil
    }
}


extension MTImageCropController: UIGestureRecognizerDelegate {
    
    // MARK: - Pinch Gesture
    
    @objc
    func pinch(_ sender: UIPinchGestureRecognizer) {
        // TODO: Zoom where the fingers are (more user friendly)
        switch sender.state {
        case .began, .changed:
            var transform = v.imageView.transform
            // Apply zoom level.
            transform = transform.scaledBy(x: sender.scale,
                                           y: sender.scale)
            v.imageView.transform = transform
        case .ended:
            pinchGestureEnded()
        case .cancelled, .failed, .possible:
            ()
        @unknown default:
            fatalError()
        }
        // Reset the pinch scale.
        sender.scale = 1.0
    }
    
    private func pinchGestureEnded() {
        var transform = v.imageView.transform
        let kMinZoomLevel: CGFloat = 1.0
        let kMaxZoomLevel: CGFloat = 3.0
        var wentOutOfAllowedBounds = false
        
        // Prevent zooming out too much
        if transform.a < kMinZoomLevel {
            transform = .identity
            wentOutOfAllowedBounds = true
        }
        
        // Prevent zooming in too much
        if transform.a > kMaxZoomLevel {
            transform.a = kMaxZoomLevel
            transform.d = kMaxZoomLevel
            wentOutOfAllowedBounds = true
        }
        
        // Animate coming back to the allowed bounds with a haptic feedback.
        if wentOutOfAllowedBounds {
            generateHapticFeedback()
            UIView.animate(withDuration: 0.3, animations: {
                self.v.imageView.transform = transform
            })
        }
    }
    
    func generateHapticFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    // MARK: - Pan Gesture
    
    @objc
    func pan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let imageView = v.imageView!
        
        // Apply the pan translation to the image.
        imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
        
        // Reset the pan translation.
        sender.setTranslation(CGPoint.zero, in: view)
        
        if sender.state == .ended {
            keepImageIntoCropArea()
        }
    }
    
    private func keepImageIntoCropArea() {
        let imageRect = v.imageView.frame
        let cropRect = v.cropArea.frame
        var correctedFrame = imageRect
        
        // Cap Top.
        if imageRect.minY > cropRect.minY {
            correctedFrame.origin.y = cropRect.minY
        }
        
        // Cap Bottom.
        if imageRect.maxY < cropRect.maxY {
            correctedFrame.origin.y = cropRect.maxY - imageRect.height
        }
        
        // Cap Left.
        if imageRect.minX > cropRect.minX {
            correctedFrame.origin.x = cropRect.minX
        }
        
        // Cap Right.
        if imageRect.maxX < cropRect.maxX {
            correctedFrame.origin.x = cropRect.maxX - imageRect.width
        }
        
        // Animate back to allowed bounds
        if imageRect != correctedFrame {
            UIView.animate(withDuration: 0.3, animations: {
                self.v.imageView.frame = correctedFrame
            })
        }
    }
    
    /// Allow both Pinching and Panning at the same time.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
