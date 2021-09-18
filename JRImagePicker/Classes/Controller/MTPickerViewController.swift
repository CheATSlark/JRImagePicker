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
    /// 选中的照片
    public var pickedImages: (([MTImagePickerPhotosModel]) -> Void)?
    /// 取消原因
    public var cancelReason:((String?)-> Void)?
    /// 选择拍照
    public var selectedShoot: Bool = false
    /// 相册选择类型
    public var mediaType: [MTImagePickerMediaType] = [.Photo]
    
    private var isHiddenStatusBar: Bool = true
    
    public override var prefersStatusBarHidden: Bool {
        isHiddenStatusBar
    }
    
    lazy var indiactor: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        if #available(iOS 13.0, *) {
            aiv.style = .large
        } else {
            // Fallback on earlier versions
            aiv.style = .gray
        }
    
        self.view.addSubview(aiv)
        aiv.center = self.view.center
        return aiv
    }()
    
    lazy var photoAssetVc: MTImagePickerController = {
        let vc = MTImagePickerController.instance(mediaType: mediaType)
        vc.maxCount = pickerMaxCount
        vc.isCrop = imageIsEdit
        vc.imagePickerDelegate = self
        vc.mediaTypes = mediaType
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    lazy var takePhotoVc: MTTakePhotoNavigationController = {
        let vc = MTTakePhotoNavigationController.instance
        if let takePhoto = vc.viewControllers.first as? MTTakePhotoController {
            takePhoto.imagePickerDelegate = self
            takePhoto.isCrop = imageIsEdit
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
        if selectedShoot == true {
            subViewController = [takePhotoVc, photoAssetVc]
            photoAssetBtn.setTitle("拍照", for: .normal)
            takePhotoBtn.setTitle("相册", for: .normal)
            indiactor.startAnimating()
        } else {
            subViewController = [photoAssetVc, takePhotoVc]
        }
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        if selectedShoot == true {
            if indiactor.isAnimating == true {
                if let vc = takePhotoVc.viewControllers.first as? MTTakePhotoController {
                    vc.start()
                    indiactor.stopAnimating()
                    indiactor.hidesWhenStopped = true
                }
            }
            
        }
    }

    @IBAction func selectIndex(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.indicateView.center = CGPoint(x: sender.center.x, y: self?.indicateView.center.y ?? 0)
        }
        
        contentCollectionView.scrollToItem(at: IndexPath(row: toolBtns.firstIndex(of: sender) ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        if selectedShoot == false {
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
        } else {
            switch sender {
            case photoAssetBtn:
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
    
    public func imagePickerControllerDidCancel(reason: String?) {
        cancelReason?(reason)
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
