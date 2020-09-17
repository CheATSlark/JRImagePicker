//
//  MTPickerViewController.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/16.
//

import UIKit

public class MTPickerViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var photoAssetBtn: UIButton!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var indicateView: UIView!
    @IBOutlet var toolBtns: [UIButton]!
    var subViewController: [UIViewController] = []
    
    lazy var photoAssetVc: MTImagePickerController = {
        let vc = MTImagePickerController.instance
        vc.maxCount = 9
        vc.isCrop = true
        vc.imagePickerDelegate = self
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    lazy var takePhotoVc: MTTakePhotoController = {
        let vc = MTTakePhotoController.instance
        return vc
    }()
    
    public class var instance:MTPickerViewController {
             get {
                 let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTPickerViewController.self))
                 let vc = storyboard.instantiateViewController(withIdentifier: "MTPickerViewController") as! MTPickerViewController
                 return vc
             }
         }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        subViewController = [photoAssetVc, takePhotoVc]
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        scrollView.contentSize = CGSize(width: screenWidth*CGFloat(subViewController.count), height: screenHeight)
        
        for (dex, vc) in subViewController.enumerated() {
            addChildViewController(vc)
            vc.view.frame = CGRect(origin: .init(x: screenWidth*CGFloat(dex), y: 0), size: scrollView.bounds.size)
            scrollView.addSubview(vc.view)
        }
        
    }

    @IBAction func selectIndex(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.indicateView.center = CGPoint(x: sender.center.x, y: self?.indicateView.center.y ?? 0)
        }
    }

}

extension MTPickerViewController: MTImagePickerControllerDelegate {
    
    private func imagePickerController(picker: MTImagePickerController, didFinishPickingWithPhotosModels models: [MTImagePickerPhotosModel]) {
        if models.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+4) { [weak self] in
                
            }
            
        }else{
        
        }
        
    }
    
    @objc func showToolBarView(isShow: Bool) {
        if isShow == true {
            stackView.isHidden = false
        }else{
            stackView.isHidden = true
        }
    }

}
