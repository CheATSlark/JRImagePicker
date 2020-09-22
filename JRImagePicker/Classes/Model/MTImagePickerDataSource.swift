//
//  MTImagePickerDataSource.swift
//  MTImagePicker
//
//  Created by Luo on 9/6/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import Foundation
import Photos


class MTImagePickerDataSource {
    
    class func fetch(mediaTypes:[MTImagePickerMediaType],complete:@escaping  ([MTImagePickerAlbumModel]) -> Void) {
        
        MTImagePickerDataSource.fetchByPhotos(mediaTypes: mediaTypes) { complete($0) }
    }
    
    // 可优化 这里简单复用代码，取数量最多的group作为默认所有相片的group
    class func fetchDefault(mediaTypes:[MTImagePickerMediaType],complete:@escaping  (MTImagePickerAlbumModel) -> Void) {
        MTImagePickerDataSource.fetchByPhotos(mediaTypes: mediaTypes) {
            if let model = ($0.max { $0.getAlbumCount() < $1.getAlbumCount() }) {
                complete(model)
            }
        }
    }
        
    class func fetchByPhotos(mediaTypes:[MTImagePickerMediaType],complete:@escaping ([MTImagePickerAlbumModel]) -> Void) {
        
        func chargeAuthorizationStatus(status: PHAuthorizationStatus,onAuthorized:@escaping () -> Void) {
            switch (status) {
            case .authorized:
                onAuthorized()
            case .denied:
                MTImagePickerDataSource.showUnAuthorize()
            case .restricted:
                MTImagePickerDataSource.showUnAuthorize()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                    guard status != .notDetermined else {
                        return
                    }
                    DispatchQueue.main.async {
                        chargeAuthorizationStatus(status: status,onAuthorized: onAuthorized )
                    }
                })
            default:
                break
            }
        }
        
        chargeAuthorizationStatus(status: PHPhotoLibrary.authorizationStatus()) {
            var models = [MTImagePickerAlbumModel]()
            func fetchAlbums() -> [PHFetchResult<AnyObject>] {
                let userAlbumsOptions = PHFetchOptions()
                userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
                userAlbumsOptions.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
                var albums = [PHFetchResult<AnyObject>]()
                albums.append(
                    PHAssetCollection.fetchAssetCollections(
                        with: PHAssetCollectionType.smartAlbum,
                        subtype: PHAssetCollectionSubtype.albumRegular,
                        options: nil) as! PHFetchResult<AnyObject>
                )
                albums.append(
                    PHAssetCollection.fetchAssetCollections(
                        with: PHAssetCollectionType.album,
                        subtype: PHAssetCollectionSubtype.any,
                        options: userAlbumsOptions) as! PHFetchResult<AnyObject>
                )
                return albums
            }
            DispatchQueue.global(qos: .default).async {
                let results = fetchAlbums()
                let options = PHFetchOptions()
                var formats = [String]()
                var arguments = [Int]()
                for type in mediaTypes {
                    formats.append("mediaType = %d")
                    if type == .Photo {
                        arguments.append(PHAssetMediaType.image.rawValue)
                    } else if type == .Video {
                        arguments.append(PHAssetMediaType.video.rawValue)
                    }
                }
                options.predicate = NSPredicate(format: formats.joined(separator: " or "), argumentArray: arguments)
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                for (_, result) in results.enumerated() {
                    result.enumerateObjects({ (collection, index, isStop) -> Void in
                        let album = collection as! PHAssetCollection
                        let assetResults = PHAsset.fetchAssets(in: album, options: options)
                        var count = 0
                        switch album.assetCollectionType {
                        case .album:
                            count = assetResults.count
                        case .smartAlbum:
                            count = assetResults.count
                        case .moment:
                            count = 0
                        @unknown default:
                            count = 0
                        }
                        
                        if count > 0 {
                            let model = MTImagePickerPhotosAlbumModel(result: assetResults as! PHFetchResult<AnyObject>, albumCount: count, albumName: album.localizedTitle)
                            model.assetCollectionSubtype = album.assetCollectionSubtype
                            models.append(model)
                        }
                    })
                }
                complete(models)
            }
        }
    }
    
    
    /// 获取最近添加的照片合集
    /// - Parameter complete: 回调照片数据
    class func fetchRecentlyAddPhotots(complete:@escaping ((MTImagePickerAlbumModel?) -> Void)) {
        
        func recentlyAddPhotos()-> MTImagePickerAlbumModel? {
            let collections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            if let album = collections.firstObject {
                let options = PHFetchOptions()
                var formats = [String]()
                var arguments = [Int]()
                formats.append("mediaType = %d")
                arguments.append(PHAssetMediaType.image.rawValue)
                options.predicate = NSPredicate(format: formats.joined(separator: " or "), argumentArray: arguments)
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let results =  PHAsset.fetchAssets(in: album, options: options)
                let model = MTImagePickerPhotosAlbumModel(result: results as! PHFetchResult<AnyObject>, albumCount: results.count, albumName: album.localizedTitle)
                model.assetCollectionSubtype = album.assetCollectionSubtype
                return model
            }else{
                return nil
            }
        }
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            complete(recentlyAddPhotos())
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                guard status != .notDetermined else { return }
                if status == .authorized {
                    complete(recentlyAddPhotos())
                }else{
                    complete(nil)
                }
            })
        default:
            complete(nil)
        }
    }
    
    
    class func showUnAuthorize() {
        DispatchQueue.main.async {
//            let alertView = UIAlertView(title: "Notice".localized, message: "照片访问权限被禁用，请前往系统设置->隐私->照片中，启用本程序对照片的访问权限".localized, delegate: nil, cancelButtonTitle: "OK".localized)
//            alertView.show()
        }
    }
}
