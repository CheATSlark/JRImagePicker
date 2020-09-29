//
//  MTPickerViewController.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/16.
//

import UIKit

public class MTPickerViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var photoAssetBtn: UIButton!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var indicateView: UIView!
    @IBOutlet weak var indicateBkgView: UIView!
    @IBOutlet var toolBtns: [UIButton]!
    var subViewController: [UIViewController] = []
    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    /// 图片选择器的最大数目
    public var pickerMaxCount = 1
    /// 是否需要编辑
    public var imageIsEdit: Bool = true
    
    public var pickedImages: (([MTImagePickerPhotosModel]) -> Void)?
    
    private var isHiddenStatusBar: Bool = true
    public override var prefersStatusBarHidden: Bool {
        isHiddenStatusBar
    }
    
    
    lazy var photoAssetVc: MTImagePickerController = {
        let vc = MTImagePickerController.instance
        vc.maxCount = pickerMaxCount
        vc.isCrop = imageIsEdit
        vc.imagePickerDelegate = self
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    lazy var takePhotoVc: MTTakePhotoNavigationController = {
        let vc = MTTakePhotoNavigationController.instance
        if let takePhoto = vc.viewControllers.first as? MTTakePhotoController {
            takePhoto.imagePickerDelegate = self
        }
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
    }

    @IBAction func selectIndex(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.indicateView.center = CGPoint(x: sender.center.x, y: self?.indicateView.center.y ?? 0)
        }
        
        contentCollectionView.scrollToItem(at: IndexPath(row: toolBtns.firstIndex(of: sender) ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        switch sender {
        case takePhotoBtn:
            if let vc = takePhotoVc.viewControllers.first as? MTTakePhotoController {
                vc.start()
            }
        default:
            if let vc = takePhotoVc.viewControllers.first as? MTTakePhotoController {
                vc.end()
            }
            break
        }
    }

}

extension MTPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolBtns.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let vc = subViewController[indexPath.row]
        if children.contains(vc) == false {
            addChild(vc)
        }
        if  cell.subviews.contains(vc.view) == false {
            vc.view.frame = cell.bounds
            cell.addSubview(vc.view)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
}


extension MTPickerViewController: MTImagePickerControllerDelegate {
    
    public func imagePickerController(models: [MTImagePickerPhotosModel]) {
        pickedImages?(models)
    }
    
    public func showToolBarView(isShow: Bool) {
        if isShow == true {
            stackView.isHidden = false
            indicateBkgView.isHidden = false
        }else{
            stackView.isHidden = true
            indicateBkgView.isHidden = true
        }
    }

}
