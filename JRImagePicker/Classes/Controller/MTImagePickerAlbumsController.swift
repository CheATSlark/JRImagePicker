//
//  MTImagePickerAlbumController.swift
//  MTImagePicker
//
//  Created by Luo on 9/6/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class MTImagePickerAlbumCell:UITableViewCell {
    
    @IBOutlet weak var lbAlbumCount: UILabel!
    @IBOutlet weak var lbAlbumName: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    
    func setup(model:MTImagePickerAlbumModel) {
        self.lbAlbumCount.text = "(\(model.getAlbumCount()))"
        self.lbAlbumName.text = model.getAlbumName()
        self.posterImageView.image = model.getAlbumImage(size: self.posterImageView.frame.size)
    }
}

class MTImagePickerAlbumsController :UITableViewController {
    
    weak var delegate:MTImagePickerDataSourceDelegate!
    private var dataSource = [MTImagePickerAlbumModel]()
    var cachingImageManger = PHCachingImageManager()
    class var instance:MTImagePickerAlbumsController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: Bundle.getResourcesBundle())
            let vc = storyboard.instantiateViewController(withIdentifier: "MTImagePickerAlbumsController") as! MTImagePickerAlbumsController
            return vc
        }
    }
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
//        self.showLoading()
        MTImagePickerDataSource.fetch(type: delegate.source, mediaTypes: delegate.mediaTypes, complete: { [unowned self](dataSource) in
            self.dataSource = dataSource
            DispatchQueue.main.async {
//                self.dismissHUD()
                self.tableView.reloadData()
                for (_, model) in dataSource.enumerated() {
                    if model.getAlbumType() == PHAssetCollectionSubtype.smartAlbumRecentlyAdded {
                        self.pushToMTImagePickerController(model: model, animate: false)
                    }
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataSource[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "MTImagePickerAlbumCell", for: indexPath as IndexPath)
        (cell as? MTImagePickerAlbumCell)?.setup(model: model)
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.dataSource[indexPath.row]
        self.pushToMTImagePickerController(model: model,animate: true)
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func pushToMTImagePickerController(model:MTImagePickerAlbumModel,animate:Bool) {
        let controller = MTImagePickerAssetsController.instance
        controller.groupModel = model
        if let photoAlbum = model as? MTImagePickerPhotosAlbumModel{
            photoAlbum.imageManager = cachingImageManger
        }
//        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: animate)
    }
    @IBAction func btnCancelTouch(_ sender: AnyObject) {
        self.delegate.didCancel()
    }
}

