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
    
    lazy var photoAssetVc: MTImagePickerController = {
        let vc = MTImagePickerController.instance
        vc.maxCount = 9
        vc.isCrop = true
        vc.imagePickerDelegate = self
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    lazy var takePhotoVc: MTTakePhotoNavigationController = {
        let vc = MTTakePhotoNavigationController.instance
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
//        let screenWidth = UIScreen.main.bounds.size.width
//        let screenHeight = UIScreen.main.bounds.size.height
//        scrollView.contentSize = CGSize(width: screenWidth*CGFloat(subViewController.count), height: screenHeight)
        
//        for (dex, vc) in subViewController.enumerated() {
//            addChildViewController(vc)
//            vc.view.frame = CGRect(origin: .init(x: screenWidth*CGFloat(dex), y: 0), size: scrollView.bounds.size)
//            scrollView.addSubview(vc.view)
//        }
        
    }

    @IBAction func selectIndex(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.indicateView.center = CGPoint(x: sender.center.x, y: self?.indicateView.center.y ?? 0)
        }
        
        contentCollectionView.scrollToItem(at: IndexPath(row: toolBtns.index(of: sender) ?? 0, section: 0), at: .centeredHorizontally, animated: true)
        switch sender {
//        case photoAssetBtn:
//            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        case takePhotoBtn:
//            scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width, y: 0), animated: true)
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
        if childViewControllers.contains(vc) == false {
            addChildViewController(vc)
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
    

    
//    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let vc = subViewController[indexPath.row] as? MTTakePhotoController {
//            vc.start()
//        }
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if let vc = subViewController[indexPath.row] as? MTTakePhotoController {
//            vc.end()
//        }
//    }
    
}


extension MTPickerViewController: MTImagePickerControllerDelegate {
    
    private func imagePickerController(picker: MTImagePickerController, didFinishPickingWithPhotosModels models: [MTImagePickerPhotosModel]) {
        if models.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now()+4) { [weak self] in
                
            }
            
        }else{
        
        }
        
    }
    
    @objc func showToolBarView(isShow: Bool) {
        if isShow == true {
            stackView.isHidden = false
            indicateBkgView.isHidden = false
        }else{
            stackView.isHidden = true
            indicateBkgView.isHidden = true
        }
    }

}
