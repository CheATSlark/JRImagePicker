//
//  MTImagePickerPhotosModel.swift
//  MTImagePicker
//
//  Created by Luo on 6/27/16.
//  Copyright © 2016 Luo. All rights reserved.
//
import UIKit
import Photos


public class MTImagePickerPhotosModel : MTImagePickerModel {
    
    public var phasset:PHAsset!
    public init(mediaType: MTImagePickerMediaType,phasset:PHAsset) {
        super.init(mediaType: mediaType)
        self.phasset = phasset
    }
    
    override func getFileName() -> String? {
        var fileName:String?
        self.fetchDataSync(){
            (data,dataUTI,orientation,infoDict) in
            if let name = (infoDict?["PHImageFileURLKey"] as? NSURL)?.lastPathComponent {
                fileName = name
            }
        }
        return fileName
    }
    
    override func getCropImage() -> UIImage? {
        
        return nil
    }
    
    override func getThumbImage(size:CGSize, asset: PHAsset)-> UIImage? {
        var img:UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isSynchronous = true
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) {
            image,infoDict in
            img = image
            
        }
        return img
    }
    
   public override func getPreviewImage() -> UIImage?{
        var img:UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = true
        var size = UIScreen.main.compatibleBounds.size
        size = CGSize(width: size.width / 3.0 , height: size.height / 3.0)
        PHImageManager.default().requestImage(for: self.phasset, targetSize: size, contentMode: .aspectFit, options: options) {
            image,infoDict in
            img = image
        }
        return img
    }
    
   public override func getImageAsync(complete:@escaping (UIImage?) -> Void) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: self.phasset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) {
            image,infoDict in
            complete(image)
        }
    }
    
    override func getVideoDurationAsync(complete:@escaping (Double) -> Void) {
        PHImageManager.default().requestAVAsset(forVideo: self.phasset, options: nil){
            avasset,_,_ in
            if let asset = avasset{
                let duration = Double(asset.duration.value) / Double(asset.duration.timescale)
                complete(duration)
            }
        }
    }
    
    override func getAVPlayerItem(complete: @escaping (AVPlayerItem?) -> Void) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestPlayerItem(forVideo: self.phasset, options: options){
            item,infoDict in
            complete(item)
        }
    }
      
    
    override func getFileSize() -> Int {
        var fileSize = 0
        self.fetchDataSync(){
            (data,dataUTI,orientation,infoDict) in
            if let d = data {
                fileSize = d.length
            }
        }
        return fileSize
    }
    
    override func getIdentity() -> String {
        return self.phasset.localIdentifier
    }
    
    private func fetchAVPlayerItemSync() -> AVPlayerItem? {
        var playerItem:AVPlayerItem?
//        let sem = DispatchSemaphore(value: 0)
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestPlayerItem(forVideo: self.phasset, options: options){
            item,infoDict in
            playerItem = item
//            sem.signal()
        }
//        sem.wait()
        return playerItem
    }
    
    private func fetchDataSync(complete:@escaping (NSData?, String?, UIImage.Orientation, [AnyHashable : Any]?) -> Void) {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        PHImageManager.default().requestImageData(for: self.phasset, options: requestOptions){
            (data,dataUTI,orientation,infoDict) in
            complete(data as NSData?, dataUTI, orientation, infoDict)
        }
    }
    
    
}

class MTImagePickerPhotosAlbumModel:MTImagePickerAlbumModel {
    
    private var result:PHFetchResult<AnyObject>
    private var _albumCount:Int
    private var _albumName:String?
    private var previousPreheatRect: CGRect = .zero
    var imageManager: PHCachingImageManager?
    
    deinit {
        
    }
    
    var assetCollectionSubtype: PHAssetCollectionSubtype?
    init(result:PHFetchResult<AnyObject>,albumCount:Int,albumName:String?) {
        self.result = result
        self._albumName = albumName
        self._albumCount = albumCount
        previousPreheatRect = .zero
    }

    override func getAlbumCount() -> Int {
        return self._albumCount
    }
    
    
    override func getAlbumType() -> PHAssetCollectionSubtype? {
        return assetCollectionSubtype
    }
    
    override func getAlbumName() -> String? {
        return self._albumName
    }
    
    override func getAlbumImage(size:CGSize) -> UIImage? {
        if let asset = self.result.object(at: 0) as? PHAsset {
            let model = MTImagePickerPhotosModel(mediaType: .Photo, phasset: asset)
            return model.getThumbImage(size: size, asset: asset)
        }
        return nil
    }
    
    func resetCachedAssets() {
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    func updateCachedAssets(in collectionView: UICollectionView) {
        let size = UIScreen.main.bounds.width/3 * UIScreen.main.scale
        let cellSize = CGSize(width: size, height: size)
        
        var preheatRect = collectionView.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -3 * preheatRect.height)
        
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        if delta > collectionView.bounds.height / 3.0 {
            
            var addedIndexPaths: [IndexPath] = []
            var removedIndexPaths: [IndexPath] = []
            
            previousPreheatRect.jr_differenceWith(rect: preheatRect, removedHandler: { removedRect in
                let indexPaths = collectionView.jr_indexPathsForElementsInRect(removedRect)
                removedIndexPaths += indexPaths
            }, addedHandler: { addedRect in
                let indexPaths = collectionView.jr_indexPathsForElementsInRect(addedRect)
                addedIndexPaths += indexPaths
            })
            
            if let assetsToStartCaching = result.jr_assetsAtIndexPaths(addedIndexPaths) as? [PHAsset], let assetsToStopCaching = result.jr_assetsAtIndexPaths(removedIndexPaths) as? [PHAsset] {
                imageManager?.startCachingImages(for: assetsToStartCaching,
                                                 targetSize: cellSize,
                                                 contentMode: .aspectFill,
                                                 options: nil)
                imageManager?.stopCachingImages(for: assetsToStopCaching,
                                                targetSize: cellSize,
                                                contentMode: .aspectFill,
                                                options: nil)
            }
            previousPreheatRect = preheatRect
        }
    }
    
    func requestImage(index: Int, targetSize: CGSize, complete:@escaping ((UIImage?, Int))->Void) -> PHImageRequestID? {
        if let asset = result[index] as? PHAsset {
         return  imageManager?.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                complete((image, index))
         })
        }else{
            return nil
        }
    }
    
    func cancelRequsetImage(requstId: PHImageRequestID){
        imageManager?.cancelImageRequest(requstId)
    }
    
    
    override func getMTImagePickerModelsListAsync(complete: @escaping ([MTImagePickerModel]) -> Void) {
        var models = [MTImagePickerModel]()
        DispatchQueue.global(qos: .default).async {
            self.result.enumerateObjects({ (asset, index, isStop) -> Void in
                if let phasset = asset as? PHAsset {
                    let mediaType:MTImagePickerMediaType = phasset.mediaType == .image ? .Photo : .Video
                    let model = MTImagePickerPhotosModel(mediaType: mediaType, phasset: phasset)
                    models.append(model)
                }
            })
            DispatchQueue.main.async {
                complete(models)
            }
        }
    }
}

extension PHFetchResult where ObjectType == AnyObject {
    func jr_assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [AnyObject] {
        if indexPaths.count == 0 { return [] }
        var assets: [AnyObject] = []
        assets.reserveCapacity(indexPaths.count)
        for indexPath in indexPaths {
            let asset = self[indexPath.item]
            assets.append(asset)
        }
        return assets
    }
}

extension CGRect {
    
    func jr_differenceWith(rect: CGRect,
                        removedHandler: (CGRect) -> Void,
                        addedHandler: (CGRect) -> Void) {
        if rect.intersects(self) {
            let oldMaxY = self.maxY
            let oldMinY = self.minY
            let newMaxY = rect.maxY
            let newMinY = rect.minY
            if newMaxY > oldMaxY {
                let rectToAdd = CGRect(x: rect.origin.x,
                                       y: oldMaxY,
                                       width: rect.size.width,
                                       height: (newMaxY - oldMaxY))
                addedHandler(rectToAdd)
            }
            if oldMinY > newMinY {
                let rectToAdd = CGRect(x: rect.origin.x,
                                       y: newMinY,
                                       width: rect.size.width,
                                       height: (oldMinY - newMinY))
                addedHandler(rectToAdd)
            }
            if newMaxY < oldMaxY {
                let rectToRemove = CGRect(x: rect.origin.x,
                                          y: newMaxY,
                                          width: rect.size.width,
                                          height: (oldMaxY - newMaxY))
                removedHandler(rectToRemove)
            }
            if oldMinY < newMinY {
                let rectToRemove = CGRect(x: rect.origin.x,
                                          y: oldMinY,
                                          width: rect.size.width,
                                          height: (newMinY - oldMinY))
                removedHandler(rectToRemove)
            }
        } else {
            addedHandler(rect)
            removedHandler(self)
        }
    }
}

internal extension UICollectionView {
    func jr_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)
        if (allLayoutAttributes?.count ?? 0) == 0 {return []}
        var indexPaths: [IndexPath] = []
        indexPaths.reserveCapacity(allLayoutAttributes!.count)
        for layoutAttributes in allLayoutAttributes! {
            let indexPath = layoutAttributes.indexPath
            indexPaths.append(indexPath)
        }
        return indexPaths
    }
}

