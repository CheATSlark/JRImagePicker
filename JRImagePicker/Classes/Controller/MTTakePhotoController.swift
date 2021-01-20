//
//  MTTakePhotoController.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/16.
//

import UIKit
import Photos

public class MTTakePhotoController: UIViewController {

    let photoCapture = JRPostPhotoCapture()
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var zoomBtn: UIButton!
    @IBOutlet weak var flipBtn: UIButton!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewToTopConstratint: NSLayoutConstraint!
    
    public weak var imagePickerDelegate:MTImagePickerControllerDelegate?
    
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    let screenWidth = UIScreen.main.bounds.size.width
    var isInited = false
    var isCrop: Bool = true
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
        // Focus
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.focusTapped(_:)))
        tapRecognizer.delegate = self
        previewViewContainer.addGestureRecognizer(tapRecognizer)
        
        // Zoom
        let pinchRecongizer = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(_:)))
        pinchRecongizer.delegate = self
        previewViewContainer.addGestureRecognizer(pinchRecongizer)
    }
    
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        previewToTopConstratint.constant = view.safeAreaInsets.top - (navigationController?.navigationBar.frame.size.height ?? 0)
    }
        
    public override var prefersStatusBarHidden: Bool {
        false
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        super.viewWillAppear(animated)
        if  photoCapture.isCaptureSessionSetup == true {
            photoCapture.startCamera {
                
            }
        }
//        imagePickerDelegate?.showToolBarView(isShow: true)
    }
    
    
    func start() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self](isTrust) in
            if isTrust == true {
                self?.photoCapture.currentAspectRatioMode = .ratio1x1
                self?.photoCapture.start(with: (self?.previewViewContainer)!) {
                    DispatchQueue.main.async {
                        self?.isInited = true
                        self?.doScaleAction()
                        self?.refreshFlashBtn()
                    }
                }
            }
        }
       
        
    }
    
    func end() {
      
        photoCapture.stopCamera()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        imagePickerDelegate?.imagePickerControllerDidCancel()
    }
    
    @IBAction func flipAction(_ sender: Any) {
        photoCapture.flipCamera {
            
        }
    }
    
    @IBAction func flashAction(_ sender: UIButton) {
        photoCapture.tryToggleFlash()
        refreshFlashBtn()
    }
    
    @IBAction func scaleAction(_ sender: UIButton) {
        doScaleAction()
    }
    
    private func doScaleAction(){
        refreshZoomBtn()
        photoCapture.tryToggleAspectRatio(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: previewHeightConstraint.constant)))
    }
    
    
    @IBAction func shootAction(_ sender: Any) {
        photoCapture.shoot { [weak self](data) in
            guard var shotImage = UIImage(data: data) else { return }
            shotImage = self?.cropImageToRation(shotImage) ?? shotImage
            self?.photoCapture.stopCamera()
            var localIdentifier: String?
            PHPhotoLibrary.shared().performChanges {
                let requset = PHAssetChangeRequest.creationRequestForAsset(from: shotImage)
                localIdentifier =  requset.placeholderForCreatedAsset?.localIdentifier
            } completionHandler: { (isSuccess, error) in
                let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier!], options: nil)
                DispatchQueue.main.async {
                    let vc = MTImageResultController.instance
                    vc.resultList = { (list) in
                        self?.imagePickerDelegate?.imagePickerController(models: list)
                    }
                    vc.list = [MTImagePickerPhotosModel(mediaType: .Photo, phasset: assetResult.firstObject!)]
                    vc.delegate = self?.imagePickerDelegate
                    vc.isCrop = self?.isCrop ?? true
                    self?.navigationController?.pushViewController(vc, animated: true)
                    self?.imagePickerDelegate?.showToolBarView(isShow: false)
                }
            }
            
        }
    }
    
    func cropImageToRation(_ image: UIImage) -> UIImage {
        let orientation: UIDeviceOrientation = JRDeviceOrientationHelper.shared.currentDeviceOrientation
        /// 初始照片尺寸
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        /// 横拍照片尺寸
        var photoHeight = imageHeight
        var photoWidth = imageWidth
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            // Swap width and height if orientation is landscape
            photoWidth = image.size.height
            photoHeight = image.size.width
        default:
            break
        }
        var ratio: CGFloat = 1.0
        switch photoCapture.currentAspectRatioMode {
        case .ratio1x1:
            ratio = 1
        case .ratio3x4:
            ratio = 3/4
        }
        
        if imageWidth/imageHeight == ratio {
            return image
        }
        
        if ratio > (photoWidth / photoHeight) {
            switch photoCapture.currentAspectRatioMode {
            case .ratio1x1:
                photoHeight = photoWidth
            case .ratio3x4:
                photoHeight = photoWidth*4/3
            }
        }else {
            switch photoCapture.currentAspectRatioMode {
            case .ratio1x1:
                photoWidth = photoHeight
            case .ratio3x4:
                photoWidth = photoHeight*3/4
            }
        }
    
       
        var original: CGPoint = .zero
        switch photoCapture.currentAspectRatioMode {
        case .ratio1x1:
            original = .init(x: 0, y: (imageHeight-imageWidth)/2)
        case .ratio3x4:
            original = .init(x: (imageWidth-imageHeight)/2, y: 0)
        }
        /*
         照片的 imageOrientation 不会随着拍照设备的位置 而改变。 设备的也是
         */
        /*
         竖直，是从 右上角 开始进行裁剪的， 坐标点 随着翻转改变。
         */
        let rect = CGRect(x: original.y, y:  original.x, width: photoHeight, height: photoWidth)
        let imageRef = image.cgImage?.cropping(to: rect)
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.bounds.size.width/photoWidth, orientation: image.imageOrientation)
    }
    
    
    @objc
    func focusTapped(_ recognizer: UITapGestureRecognizer) {
        guard isInited else {
            return
        }
        focus(recognizer: recognizer)
    }
    
    func focus(recognizer: UITapGestureRecognizer) {

        let point = recognizer.location(in: previewViewContainer)
        
        // Focus the capture
        let viewsize = previewViewContainer.bounds.size
        let newPoint = CGPoint(x: point.x/viewsize.width, y: point.y/viewsize.height)
        photoCapture.focus(on: newPoint)
        
        // Animate focus view
        focusView.center = point
        configureFocusView(focusView)
        view.addSubview(focusView)
        animateFocusView(focusView)
    }
    
    @objc
    func pinch(_ recognizer: UIPinchGestureRecognizer) {
        guard isInited else {
            return
        }
        zoom(recognizer: recognizer)
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        photoCapture.zoom(began: recognizer.state == .began, scale: recognizer.scale)
    }
    
    
    private func refreshFlashBtn() {
        switch photoCapture.currentFlashMode {
        case .on:
            flashBtn.isSelected = true
        case .off:
            flashBtn.isSelected = false
        }
    }
    
    private func refreshZoomBtn() {
        switch photoCapture.currentAspectRatioMode {
        case .ratio1x1:
            previewHeightConstraint.constant = screenWidth*4/3
            zoomBtn.setImage(Bundle.getImage(name: "photo_3_4"), for: .normal)
        case .ratio3x4:
            previewHeightConstraint.constant = screenWidth
            zoomBtn.setImage(Bundle.getImage(name: "photo_1_1"), for: .normal)
            
        }
    }
    
    func configureFocusView(_ v: UIView) {
        v.alpha = 0.0
        v.backgroundColor = UIColor.clear
        v.layer.borderColor = UIColor.green.cgColor
        v.layer.borderWidth = 1.0
        v.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    func animateFocusView(_ v: UIView) {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 3.0, options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        v.alpha = 1.0
                        v.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }, completion: { _ in
            v.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            v.removeFromSuperview()
        })
    }
    
}

extension MTTakePhotoController: UIGestureRecognizerDelegate {
    
}

class MTTakePhotoNavigationController: UINavigationController {
    class var instance:MTTakePhotoNavigationController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTTakePhotoNavigationController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "MTTakePhotoNavigationController") as! MTTakePhotoNavigationController
            return vc
        }
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}

extension UIViewController {
    func configNavibarColor(_ color: UIColor){
        navigationController?.navigationBar.isTranslucent = true
        if let barSize = navigationController?.navigationBar.bounds.size {
            navigationController?.navigationBar.setBackgroundImage(JColorConveredImage(color: color, size:barSize), for: .default)
        }
        navigationController?.navigationBar.shadowImage = UIImage()
    }
}
