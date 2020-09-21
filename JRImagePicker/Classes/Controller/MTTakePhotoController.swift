//
//  MTTakePhotoController.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/16.
//

import UIKit

class MTTakePhotoController: UIViewController {

    
//    @IBOutlet weak var navigationBar: UINavigationBar!
    let photoCapture = JRPostPhotoCapture()
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var zoomBtn: UIButton!
    @IBOutlet weak var flipBtn: UIButton!
    @IBOutlet weak var previewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewToTopConstratint: NSLayoutConstraint!
    @IBOutlet weak var previewToNavibarConstraint: NSLayoutConstraint!
    
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    class var instance:MTTakePhotoController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTTakePhotoController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "MTTakePhotoController") as! MTTakePhotoController
            return vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        // Do any additional setup after loading the view.
        refreshZoomBtn()
        refreshFlashBtn()
    }
        
    func start() {
        photoCapture.start(with: previewViewContainer) {
            
        }
    }
    
    func end() {
        photoCapture.stopCamera()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        
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
        refreshZoomBtn()
        photoCapture.tryToggleAspectRatio(frame: CGRect(origin: .zero, size: .init(width: screenWidth, height: previewHeightConstraint.constant)))
    }
    
    @IBAction func shootAction(_ sender: Any) {
        photoCapture.shoot { (data) in
            
        }
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
            previewToTopConstratint.priority = .defaultLow
            previewToNavibarConstraint.priority = .defaultHigh
            previewHeightConstraint.constant = screenWidth
            zoomBtn.setImage(Bundle.getImage(name: "photo_1_1"), for: .normal)
        case .ratio3x4:
            previewToTopConstratint.priority = .defaultHigh
            previewToNavibarConstraint.priority = .defaultLow
            previewHeightConstraint.constant = screenWidth*4/3
            zoomBtn.setImage(Bundle.getImage(name: "photo_3_4"), for: .normal)
        case .ratio9x16:
            previewToTopConstratint.priority = .defaultHigh
            previewToNavibarConstraint.priority = .defaultLow
            previewHeightConstraint.constant = screenWidth*16/9
            zoomBtn.setImage(Bundle.getImage(name: "photo_9_16"), for: .normal)
        }
    }
    
}

extension MTTakePhotoController: UINavigationBarDelegate {
    func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
        
    }
    

}

class MTTakePhotoNavigationController: UINavigationController {
    class var instance:MTTakePhotoNavigationController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTTakePhotoNavigationController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "MTTakePhotoNavigationController") as! MTTakePhotoNavigationController
            return vc
        }
    }
}
