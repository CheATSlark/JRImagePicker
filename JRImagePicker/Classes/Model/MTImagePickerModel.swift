//
//  ImageSelectorViewModel.swift
//  CMBMobile
//
//  Created by Luo on 5/9/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

func ==(lhs:MTImagePickerModel, rhs:MTImagePickerModel) -> Bool {
    return lhs.getIdentity() == rhs.getIdentity()
}

public class MTImagePickerModel:NSObject {
    
    // 实现自定义的array contains
    override public func isEqual(_ object: Any?) -> Bool {
        guard let obj = object as? MTImagePickerModel else { return false }
        return obj.getIdentity() == self.getIdentity()
    }
    
    public var mediaType:MTImagePickerMediaType
    
    public var croppedImage: UIImage?
    public var uploadImageUrl: String?
    
    init(mediaType:MTImagePickerMediaType) {
        self.mediaType = mediaType
    }
    
    func getIdentity() -> String {
        fatalError("getIdentity has not been implemented")
    }
    
    func getFileName() -> String? {
        fatalError("getFileName has not been implemented")
    }
    
    func getThumbImage(size:CGSize, asset: PHAsset)-> UIImage? {
        fatalError("getThumbImage has not been implemented")
    }
    
    func getCropImage() -> UIImage? {
        fatalError("getCropImage has not been implemented")
    }
    
   public func getPreviewImage() -> UIImage?{
        fatalError("getPreviewImage has not been implemented")
    }
    
   public func getImageAsync(complete: @escaping (UIImage?) -> Void) {
        fatalError("getImageAsync has not been implemented")
    }
    
    func getVideoDurationAsync(complete: @escaping (Double) -> Void) {
        fatalError("getVideoDurationAsync has not been implemented")
    }
    
    func getAVPlayerItem (complete: @escaping (AVPlayerItem?) -> Void) {
        fatalError("getAVPlayerItem has not been implemented")
    }
    
    func getFileSize() -> Int {
        fatalError("getFileSize has not been implemented")
    }
}


class MTImagePickerAlbumModel:NSObject {
    
    func getAlbumName() -> String? {
        fatalError("getAlbumName has not been implemented")
    }
    
    func getAlbumImage(size:CGSize) -> UIImage? {
        fatalError("getAlbumImage has not been implemented")
    }
    
    func getAlbumCount() -> Int {
        fatalError("getAlbumCount has not been implemented")
    }
    
    func getMTImagePickerModelsListAsync(complete: @escaping ([MTImagePickerModel]) -> Void) {
        fatalError("getMTImagePickerModelsAsync has not been implemented")
    }
    
    func getAlbumType()-> PHAssetCollectionSubtype? {
        fatalError("getAlbimType has not been implemented")
    }
}

extension String  {
    
    var albumCnName: String {
        if self.isEmpty {return ""}
        switch self {
        case "Recently Deleted":
            return "最近删除"
        case "Recents":
            return "最近项目"
        case "Recently Added":
            return "最近添加"
        case "Live Photos":
            return "实况照片"
        case "Screenshots":
            return "截屏"
        default:
            return self
        }
    }
}
