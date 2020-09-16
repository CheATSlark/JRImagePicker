//
//  JYPCropView.swift
//  23
//
//  Created by 焦瑞洁 on 2020/5/27.
//  Copyright © 2020 ddcx. All rights reserved.
//

import UIKit

class JYPCropView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topCurtain: UIView!
    @IBOutlet weak var cropArea: UIView!
    @IBOutlet weak var bottomCurtain: UIView!
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftCurtain: UIView!
    @IBOutlet weak var rightCurtain: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var hLine1: UIView!
    @IBOutlet weak var hLine2: UIView!
    @IBOutlet weak var vLine1: UIView!
    @IBOutlet weak var vLine2: UIView!
    
    @IBOutlet weak var originalBtn: UIButton!
    private var selectedBtn: UIButton?
    private var areaAsepct: NSLayoutConstraint?
    
    
    
    var selectedIndex: IndexPath = IndexPath(row: 0, section: 0)
    var list: [MTImagePickerPhotosModel]  = []
    override func awakeFromNib() {
        super.awakeFromNib()

        let lines = [vLine1, vLine2, hLine1, hLine2]
        for line in lines {
            line?.backgroundColor = .white
            line?.addShader(shadowRadius: 2, alpha: 0.5)
        }
        cropArea.layer.borderColor = UIColor.white.cgColor
        cropArea.layer.borderWidth = 0.9
        selectedBtn = originalBtn
        
    }
    
    
    
    func setConfig(image: UIImage) {
        let ratio = image.size.width/image.size.height
        setupLayout(with: image, ratio: ratio)
        topCurtain.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        bottomCurtain.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        leftCurtain.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        rightCurtain.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toolbar.backgroundColor = jColor(color: 0x111111)
        contentView.backgroundColor = jColor(color: 0x111111)
    }
    
    
    
    private func setupLayout(with image: UIImage, ratio: CGFloat) {
        imageView.image = image
        updateAspect(multiplier: ratio)
        contentView.setNeedsLayout()
        layoutUnderImageView(ratio: ratio)
        
        // Fit image differently depnding on its ratio.
        
    }
    
    
    
    func layoutUnderImageView(ratio: CGFloat){
        guard let image = imageView.image else {
            return
        }
        
        let imageRatio = image.size.width / image.size.height
        
        var imageWidth: CGFloat = cropArea.bounds.width
        var imageHeight: CGFloat = cropArea.bounds.height
        
        if ratio > imageRatio {
            // 裁剪框的宽高比， 大于  照片的宽高比
            // 保持图片的原始大小
            let scaledDownRatio = (UIScreen.main.bounds.width - leftCurtain.bounds.size.width*2) / image.size.width
            imageWidth = image.size.width * scaledDownRatio
            imageHeight = image.size.height * scaledDownRatio
        } else if ratio < imageRatio {
            // 裁剪框的宽高比， 小雨 照片的宽高比
            imageWidth = imageHeight * CGFloat(imageRatio)
        } else {
           // keep
        }
        imageView.bounds = CGRect(origin: .zero, size: CGSize(width: imageWidth, height: imageHeight))
        imageView.center = contentView.center
    }
    
    @IBAction func chooseOriginalSize(_ sender: Any) {
        guard let image = imageView.image else { return }
        let ratio = image.size.width/image.size.height
        updateAspect(multiplier: ratio)
        layoutUnderImageView(ratio: ratio)
    }
    
    @IBAction func chooseSizeAction(_ sender: UIButton) {
        selectedBtn?.isSelected = false
        sender.isSelected = true
        selectedBtn = sender
    }
    
    @IBAction func sizeOne(_ sender: Any) {
        updateAspect(multiplier: 16/9)
        layoutUnderImageView(ratio: 16/9)
    }
    
    @IBAction func sizeTwo(_ sender: Any) {
        updateAspect(multiplier: 4/3)
        layoutUnderImageView(ratio: 4/3)
    }
    @IBAction func sizeThree(_ sender: Any) {
        updateAspect(multiplier: 1)
        layoutUnderImageView(ratio: 1)
        
    }
    
    @IBAction func sizeFour(_ sender: Any) {
        updateAspect(multiplier: 3/4)
        layoutUnderImageView(ratio: 3/4)
    }
    
    @IBAction func sizeFive(_ sender: Any) {
        updateAspect(multiplier: 9/16)
        layoutUnderImageView(ratio: 9/16)
    }
    
    @IBAction func rotation(_ sender: Any) {
        if let originalImage = imageView.image {
            let size = CGSize(width: originalImage.size.height, height: originalImage.size.width)
            UIGraphicsBeginImageContext(size)
            let currentContext = UIGraphicsGetCurrentContext()
            currentContext?.translateBy(x: 0, y: size.height)
            currentContext?.scaleBy(x: 1.0, y: -1.0)
            currentContext?.rotate(by: .pi/2)
            
            currentContext?.translateBy(x: 0, y: -size.width)
            currentContext?.scaleBy(x: size.height/size.width, y: size.width/size.height)
            
            currentContext?.draw(originalImage.cgImage!, in: CGRect(origin: .zero, size: size))

            if let lastImage =  UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                setConfig(image: lastImage)
            }else{
                 UIGraphicsEndImageContext()
            }
        }
        
        
        
        
//        if let originalImage = imageView.image?.cgImage {
//            switch imageView.image?.imageOrientation {
//            case .right:
//                let  lastImage =  UIImage(cgImage: originalImage, scale: 1.0, orientation: .up)
//                setConfig(image: lastImage)
//            case .left:
//                let  lastImage =  UIImage(cgImage: originalImage, scale: 1.0, orientation: .down)
//                setConfig(image: lastImage)
//            case .down:
//                let  lastImage =  UIImage(cgImage: originalImage, scale: 1.0, orientation: .right)
//                setConfig(image: lastImage)
//            case .up:
//                let  lastImage =  UIImage(cgImage: originalImage, scale: 1.0, orientation: .left)
//                setConfig(image: lastImage)
//            default:
//                break
//            }
//        }
    }
    
    
    private func updateAspect(multiplier: CGFloat){
        if let aspect = areaAsepct , cropArea.constraints.contains(aspect){
            cropArea.removeConstraint(aspect)
        }
        let c = NSLayoutConstraint(item: cropArea, attribute: .width, relatedBy: .equal, toItem: cropArea, attribute: .height, multiplier: multiplier, constant: 0)
        areaAsepct = c
        areaAsepct?.priority = UILayoutPriority(rawValue: 1000)
        cropArea.addConstraint(c)
        cropArea.layoutIfNeeded()
    }
    
}

//extension JYPCropView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        list.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! PostedSingleImageClCell
//        let model = list[indexPath.row]
//        model.getImageAsync { (image) in
//            cell.imageView.image = image
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 65, height: 65)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        selectedIndex = indexPath
//        let model = list[indexPath.row]
//        model.getImageAsync { [weak self](image) in
//            if let original = image {
//                self?.setupLayout(with: original, ratio: 1)
//            }
//        }
//       
//    }
//    
//}
