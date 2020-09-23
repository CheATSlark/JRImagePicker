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

public protocol MTImagePickerControllerDelegate:NSObjectProtocol {
   
    func imagePickerController(models:[MTImagePickerPhotosModel])
    
    func imagePickerControllerDidCancel()
    
    func showToolBarView(isShow: Bool)
}

extension MTImagePickerControllerDelegate {
    func imagePickerController(models:[MTImagePickerPhotosModel]) {
        
    }
    public func imagePickerControllerDidCancel() {
        
    }
    func showToolBarView(isShow: Bool) {
        
    }
}

public class MTImagePickerController:UINavigationController {
    
    public weak var imagePickerDelegate:MTImagePickerControllerDelegate?
    public var mediaTypes:[MTImagePickerMediaType]  = [.Photo]
    public var maxCount: Int = Int.max
    public var isCrop: Bool = false
    
    public var selectedSource = [MTImagePickerModel]()
   
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.tintColor = jColor(color: 0x75C6C1)
    }
}

public protocol MTImagePickerDataSourceDelegate:NSObjectProtocol {
    var selectedSource:[MTImagePickerModel] { get set }
    var maxCount:Int { get }
    var mediaTypes:[MTImagePickerMediaType] { get }

    func didFinishPicking()
    func didCancel()
    func showToolBarView(isShow: Bool)
}

extension MTImagePickerController:MTImagePickerDataSourceDelegate {

    public func didFinishPicking() {
        if let models  = selectedSource as? [MTImagePickerPhotosModel] {
            let vc = MTImageResultController.instance
            vc.resultList = { [weak self](list) in
                self?.imagePickerDelegate?.imagePickerController(models: list)
            }
            vc.list = models
            self.pushViewController(vc, animated: true)
        }
    }

    public func didCancel() {
        imagePickerDelegate?.imagePickerControllerDidCancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    public func showToolBarView(isShow: Bool) {
        imagePickerDelegate?.showToolBarView(isShow: isShow)
    }
    
}


