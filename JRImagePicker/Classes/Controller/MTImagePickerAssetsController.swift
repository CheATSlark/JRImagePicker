//
//  ImageSelectorViewController.swift
//  CMBMobile
//
//  Created by Luo on 5/9/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreImage
import Foundation
import Photos
import PhotosUI

class MTImagePickerAssetsController :UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    weak var delegate:MTImagePickerDataSourceDelegate!
    var groupModel:MTImagePickerAlbumModel?{
        didSet{
            if let photoAlbum = groupModel as? MTImagePickerPhotosAlbumModel{
                photoAlbum.imageManager = PHCachingImageManager()
            }
        }
    }
    @IBOutlet weak var collectionView: MTImagePickerCollectionView!
    @IBOutlet weak var lbSelected: UILabel!
    @IBOutlet weak var btnPreview: UIButton!
    @IBOutlet weak var imageCollection: MTImagePickerCollectionView!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var manageBtn: UIButton!
    
    private var dataSource = [MTImagePickerModel]()
    private var initialScrollDone:Bool = false
    private var titleBtn = UIButton(type: .custom)
    
    lazy var albumsView: ImageAlbumsView? = {
        
        let albums = Bundle(for: MTImagePickerAssetsController.self).loadNibNamed("ImageAlbumsView", owner: nil, options: nil)?.first as? ImageAlbumsView
        if let albums = albums {
            albums.frame = view.bounds
            albums.delegate = delegate
            view.addSubview(albums)
        }
        albums?.chooseAlbum = { [weak self, albums](group) in
            self?.titleBtn.isSelected = !(self?.titleBtn.isSelected ?? true)
            self?.change(group: group)
        }
        return albums
    }()
    
    
    deinit {
        if let albumModel = groupModel as? MTImagePickerPhotosAlbumModel {
            albumModel.resetCachedAssets()
        }
    }
    
    class var instance:MTImagePickerAssetsController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTImagePickerController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "MTImagePickerController") as! MTImagePickerAssetsController
            vc.buildMiddleButton()
            return vc
        }
    }
    
    
    private func buildMiddleButton() {
        titleBtn.setTitleColor(UIColor.white, for: .normal)
        titleBtn.titleLabel?.font = UIFont.init(name: "PingFangSC-Medium", size: 18)
        titleBtn.bounds = CGRect(origin: .zero, size: .init(width: 100, height: 40))
        titleBtn.addTarget(self, action: #selector(showAlbumsView(sender:)), for: .touchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    @objc
    private func showAlbumsView(sender: UIButton){
        sender.isSelected = !sender.isSelected
        albumsView?.isHidden = !sender.isSelected
        if sender.isSelected == true {
            albumsView?.fetchAlbums()
        }
    }
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavibarColor()
        loadImages()
        if #available(iOS 14.0, *){
            if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
                manageBtn.isHidden = false
            }else{
                manageBtn.isHidden = true
            }
        }else{
            manageBtn.isHidden = true
        }
        PHPhotoLibrary.shared().register(self)
    }
    
    
    
    func loadImages(){
        if let title = self.groupModel?.getAlbumName() {
            titleBtn.set(image: Bundle.getImage(name: "pull_down"), title: title, titlePosition: .left, additionalSpacing: 4, state: .normal)
            titleBtn.set(image: Bundle.getImage(name: "pull_up"), title: title, titlePosition: .left, additionalSpacing: 4, state: .selected)
        }

        if self.groupModel == nil {
            MTImagePickerDataSource.fetchRecentlyAddPhotots { (group) in
                if group == nil {
                    /// 没有获取到图片
                }else{
                    group?.getMTImagePickerModelsListAsync(complete: { [weak self](models) in
                        self?.dataSource = models
                        self?.collectionView.reloadData()
                        self?.scrollToBottom()
                    })
                }
            }
        }else{
            self.groupModel?.getMTImagePickerModelsListAsync { (models) in
                self.dataSource = models
                self.collectionView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func change(group: MTImagePickerAlbumModel){
        groupModel = group
        loadImages()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
        self.lbSelected.text = String(delegate.selectedSource.count)
        self.lbSelected.isHidden = delegate.selectedSource.count == 0
        let isShow = !(delegate.selectedSource.count == 0)
        self.btnPreview.isEnabled = isShow
        if delegate.maxCount > 1 {
            toolbarView.isHidden = !isShow
            self.delegate.showToolBarView(isShow: !isShow)
        }else{
            self.delegate.showToolBarView(isShow: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialScrollDone {
            self.initialScrollDone = true
            self.scrollToBottom()
        }
    }
    
    
    open override func didReceiveMemoryWarning() {
        if let albumModel = groupModel as? MTImagePickerPhotosAlbumModel {
            albumModel.resetCachedAssets()
        }
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == imageCollection {
            if let albumModel = groupModel as? MTImagePickerPhotosAlbumModel {
                albumModel.updateCachedAssets(in: imageCollection)
            }
        }
    }
    
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! MTImagePickerCell
        if delegate.maxCount == 1 {
            cell.btnCheck.isHidden = true
        }else{
            cell.btnCheck.isHidden = false
        }
        let model = self.dataSource[indexPath.row]
        ///  视频
        if model.mediaType == .Video   {
            cell.videoView.isHidden = false
            model.getVideoDurationAsync(){
                duration in
                DispatchQueue.main.async {
                    cell.videoDuration.text = duration.timeFormat()

                }
            }
        } else {
            cell.videoView.isHidden = true
        }
        
        /// 图片
        cell.indexPath = indexPath
        if let albumModel = groupModel as? MTImagePickerPhotosAlbumModel {
            // 在不同的集合里，PHImageRequestID 的值 可以重复。
            
            let imageRequstId = albumModel.requestImage(index: indexPath.row, targetSize: cellSize()) { (image, index) in
                // 对应的cell 展示图片
                if cell.indexPath.row == index {
                    if let resultImage = image {
                        cell.imageView.image = resultImage
                        cell.imageId = nil
                    }
                }
           }
            
           // 滑动的时候取消上次还没请求回来的请求
           if let imageId = cell.imageId, let requestId = imageRequstId, imageId != requestId {
                albumModel.cancelRequsetImage(requstId: imageId)
            }
            cell.imageId = imageRequstId
        }
        
        /// 按钮状态
        cell.btnCheck.isSelected = delegate.selectedSource.contains(model)
        if let dex = delegate.selectedSource.firstIndex(of: model) {
            cell.btnCheck.setTitle("\(dex+1)", for: .selected)
        }
        cell.btnCheck.addTarget(self, action: #selector(MTImagePickerAssetsController.btnCheckTouch(_:)), for: .touchUpInside)
        cell.leading.constant = self.collectionView.leading.constant
        cell.trailing.constant = self.collectionView.leading.constant
        cell.top.constant = self.collectionView.leading.constant * 2
        
        UIView.performWithoutAnimation {
            cell.layoutIfNeeded()
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if delegate.maxCount == 1 {
            delegate.selectedSource.append(self.dataSource[indexPath.row])
            delegate.didFinishPicking()
        }else{
            self.pushToImageSelectorPreviewController(initialIndexPath: indexPath, dataSource: self.dataSource)
        }
        
        delegate.showToolBarView(isShow: false)
    }
    
    @objc func btnCheckTouch(_ sender:UIButton) {
        if delegate.selectedSource.count < delegate.maxCount || sender.isSelected == true {
            sender.isSelected = !sender.isSelected
            let index = (sender.superview?.superview as! MTImagePickerCell).indexPath.row
            if sender.isSelected {
                delegate.selectedSource.append(self.dataSource[index])
                sender.heartbeatsAnimation(duration: 0.15)
            }else {
                if let removeIndex = delegate.selectedSource.firstIndex(of: self.dataSource[index]) {
                    delegate.selectedSource.remove(at: removeIndex)
                    collectionView.reloadData()
                }
            }
            if let dex = delegate.selectedSource.firstIndex(of: self.dataSource[index]) {
                sender.setTitle("\(dex+1)", for: .selected)
            }
            self.lbSelected.text = String(delegate.selectedSource.count)
            self.lbSelected.isHidden = delegate.selectedSource.count == 0
            self.lbSelected.heartbeatsAnimation(duration: 0.15)
            self.btnPreview.isEnabled = !(delegate.selectedSource.count == 0)
        } else {

        }
        if delegate.selectedSource.count > 0 {
            toolbarView.isHidden = false
            delegate.showToolBarView(isShow: false)
        }else{
            toolbarView.isHidden = true
            delegate.showToolBarView(isShow: true)
        }
    }
    
    //旋转处理
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if UIApplication.shared.statusBarOrientation != .portrait {
            self.collectionView.prevItemSize = (self.collectionView.collectionViewLayout as! MTImagePickerFlowLayout).itemSize
            self.collectionView.prevOffset = self.collectionView.contentOffset.y
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func cellSize() -> CGSize {
        let size = UIScreen.main.bounds.width/3 * UIScreen.main.scale
        return CGSize(width: size, height: size)
    }
    
    //MARK: private methods
    private func scrollToBottom() {
        if self.dataSource.count > 0 {
            let indexPath = IndexPath(row: self.dataSource.count - 1 , section: 0)
            self.collectionView.scrollToItem(at: indexPath, at:.bottom, animated: false)
        }
    }
    
    private func pushToImageSelectorPreviewController(initialIndexPath:IndexPath?,dataSource:[MTImagePickerModel]) {
        let vc = MTImagePickerPreviewController.instance
        vc.dataSource = dataSource
        vc.delegate = delegate
        vc.initialIndexPath = initialIndexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: IBActions
    @IBAction func btnFinishTouch(_ sender: AnyObject) {
        delegate.didFinishPicking()
    }
    
    @IBAction func btnPreviewTouch(_ sender: AnyObject) {
        let dataSource = delegate.selectedSource
        self.pushToImageSelectorPreviewController(initialIndexPath: nil, dataSource: dataSource)
    }
    @IBAction func btnCancelTouch(_ sender: AnyObject) {
        delegate.didCancel()
    }
    
    @IBAction func addResource(_ sender: Any) {
        if #available(iOS 14.0, *) {
        
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            self.presentingViewController?.view.backgroundColor = .black
        }
    }
}

extension MTImagePickerAssetsController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            MTImagePickerDataSource.fetchRecentlyAddPhotots { (group) in
                self?.groupModel = group
                self?.loadImages()
            }
        }
        
    }
}



public class MTImagePickerCollectionView:UICollectionView {
    @IBOutlet weak var trailing: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
   public var prevItemSize:CGSize?
   public var prevOffset:CGFloat = 0
}


private extension UIButton {
    
    func set(image anImage: UIImage?, title: String,
             titlePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State){
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)
        
        positionLabelRespectToImage(title: title, position: titlePosition, spacing: additionalSpacing)
        
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }
    
    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode,
        spacing: CGFloat) {
        let imageSize = self.imageRect(forContentRect: self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes: [NSAttributedString.Key.font: titleFont!])
         
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
         
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + spacing),
                left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .bottom:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + spacing),
                left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                right: -(titleSize.width * 2 + spacing))
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -spacing)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
         
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
    
}
