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
    
    lazy var photoAssetVc: MTImagePickerController = {
        let vc = MTImagePickerController.instance
        vc.maxCount = 1
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
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width*2, height: UIScreen.main.bounds.size.height)
        let assetView = photoAssetVc.view
        assetView?.frame = scrollView.bounds
        scrollView.addSubview(photoAssetVc.view)
    
        let takePhotoView = takePhotoVc.view
        takePhotoView?.frame = CGRect(origin: .init(x: 0, y: scrollView.bounds.size.width), size: scrollView.bounds.size)
        scrollView.addSubview(takePhotoVc.view)
    
        addChildViewController(photoAssetVc)
        addChildViewController(takePhotoVc)
    }

    
}

extension MTPickerViewController: MTImagePickerControllerDelegate {
    
    func imagePickerController(picker: MTImagePickerController, didFinishPickingWithPhotosModels models: [MTImagePickerPhotosModel]) {
        if models.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+4) { [weak self] in
                
            }
            
        }else{
        
        }
        
    }
}
