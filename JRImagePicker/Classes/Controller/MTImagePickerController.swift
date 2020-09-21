//
//  File.swift
//  MTImagePicker
//
//  Created by Luo on 9/9/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit

@objc public enum MTImagePickerMediaType:Int {
    case Photo
    case Video
}


@objc public protocol MTImagePickerControllerDelegate:NSObjectProtocol {
    // Implement it when setting source to MTImagePickerSource.ALAsset
//    @objc optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithAssetsModels models:[MTImagePickerAssetsModel])
    
    // Implement it when setting source to MTImagePickerSource.Photos
    @available(iOS 8.0, *)
    @objc optional func imagePickerController(picker:MTImagePickerController, didFinishPickingWithPhotosModels models:[MTImagePickerPhotosModel])
    
    @objc optional func imagePickerControllerDidCancel(picker: MTImagePickerController)
    
    @objc optional func showToolBarView(isShow: Bool)
}

public class MTImagePickerController:UINavigationController {
    
    public weak var imagePickerDelegate:MTImagePickerControllerDelegate?
    public var mediaTypes:[MTImagePickerMediaType]  = [.Photo]
    public var maxCount: Int = Int.max
    public var isCrop: Bool = false
    
    public var selectedSource = [MTImagePickerModel]()
    private var _source = MTImagePickerSource.Photos
    public var source:MTImagePickerSource {
        get {
            return self._source
        }
        set {
            self._source = newValue
        }
    }
    
    public var mediaTypesNSArray:NSArray {
        get {
            let arr = NSMutableArray()
            for mediaType in self.mediaTypes {
                arr.add(mediaType.rawValue)
            }
            return arr
        }
        set {
            self.mediaTypes.removeAll()
            for mediaType in newValue {
                if let intType = mediaType as? Int {
                    if intType == 0 {
                        self.mediaTypes.append(.Photo)
                    } else if intType == 1 {
                        self.mediaTypes.append(.Video)
                    }
                }
            }
        }
    }
    

    public class var instance:MTImagePickerController {
        get {
            let controller = MTImagePickerAssetsController.instance
            MTImagePickerDataSource.fetchRecentlyAddPhotots { (group) in
                controller.groupModel = group
            }
            let navigation = MTImagePickerController(rootViewController: controller)
            controller.delegate = navigation
            return navigation
        }
    }
    
    public class var instancePhoto:MTImagePickerController {
        get {
            let controller = MTTakePhotoController.instance
            let navigation = MTImagePickerController(rootViewController: controller)
            return navigation
        }
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = jColor(color: 0x75C6C1)
    }
}

protocol MTImagePickerDataSourceDelegate:NSObjectProtocol {
    var selectedSource:[MTImagePickerModel] { get set }
    var maxCount:Int { get }
    var mediaTypes:[MTImagePickerMediaType] { get }
    var source:MTImagePickerSource { get }
    func didFinishPicking()
    func didCancel()
    func showToolBarView(isShow: Bool)
}

extension MTImagePickerController:MTImagePickerDataSourceDelegate {

    func didFinishPicking() {
        if self.source == .Photos {
            self.imagePickerDelegate?.imagePickerController?(picker:self, didFinishPickingWithPhotosModels: selectedSource as! [MTImagePickerPhotosModel])
            if isCrop == true && selectedSource.count > 0 {
                
                let pVc = self.presentingViewController
                let vc = MTImageCropController.instance
                vc.modalPresentationStyle = .fullScreen
                vc.original = selectedSource[0]
                vc.didFinishCropping = { [weak vc](image) in
                    
                     vc?.dismiss(animated: true, completion: nil)
                }
                self.dismiss(animated: false) { [weak pVc] in
                    pVc?.present(vc, animated: true, completion: nil)
                }
            }else{
                 self.dismiss(animated: true, completion: nil)
            }
            
        } else {
//            self.imagePickerDelegate?.imagePickerController?(picker:self, didFinishPickingWithAssetsModels: selectedSource as! [MTImagePickerAssetsModel])
        }
    }

    func didCancel() {
        imagePickerDelegate?.imagePickerControllerDidCancel?(picker: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showToolBarView(isShow: Bool) {
        if  imagePickerDelegate?.responds(to: #selector(showToolBarView(isShow:))) == true {
            imagePickerDelegate?.showToolBarView?(isShow: isShow)
        }
        
    }
    
}


