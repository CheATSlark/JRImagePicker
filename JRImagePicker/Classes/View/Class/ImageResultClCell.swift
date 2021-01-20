//
//  ImageResultClCell.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/21.
//

import UIKit

class ImageResultClCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollview: UIScrollView!
    var imageView: UIImageView! = UIImageView()
    @IBOutlet weak var clipBtn: UIButton!
    @IBOutlet weak var clipView: UIView!
    @IBOutlet weak var cropViewOffConstraint: NSLayoutConstraint!
    
    fileprivate var model:MTImagePickerModel!
    var pushCropController: ((UIViewController)->Void)?
    var isCrop: Bool? {
        didSet {
            clipView.isHidden = !(isCrop ?? true)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollview.zoomScale = 1
        scrollview.minimumZoomScale = 1
        scrollview.maximumZoomScale = 3
        scrollview.contentSize = CGSize.zero
        scrollview.delegate = self
//        clipView.corner(byRoundingCorners: [.topLeft,.bottomLeft], radii: 3, CGRect(origin: .zero, size: .init(width: 62.5, height: 30)))
//        clipView.backgroundColor = JTextMidColor
        scrollview.addSubview(imageView)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollview.zoomScale = 1.0
        scrollview.contentSize = CGSize.zero
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        scrollview.zoomScale = 1.0
        scrollview.contentSize = CGSize.zero
        if let _image = imageView.image {
            let bounds = self.bounds
            let boundsDept = bounds.width / bounds.height
            let imgDept = _image.size.width / _image.size.height
            // 图片长宽和屏幕的宽高进行比较 设定基准边
            if imgDept < boundsDept {
                imageView.frame = CGRect(x: 0, y: 0, width: bounds.height * imgDept, height: bounds.height)
            } else {
                imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.width / imgDept)
            }
            self.scrollview.layoutIfNeeded()
            self.scrollview.frame.origin = CGPoint.zero
            imageView.center = scrollview.center
            cropViewOffConstraint.constant = imageView.frame.origin.y + imageView.frame.size.height - 50
            if cropViewOffConstraint.constant > self.bounds.height - 50 {
                cropViewOffConstraint.constant = self.bounds.height - 50
            }
            
        }
        
    }
    
    
    func initWithModel(_ model:MTImagePickerModel) {
        self.model = model
        if let croppedImage = model.croppedImage {
            self.imageView.image = croppedImage
        }else{
            self.imageView.image = model.getPreviewImage()
            model.getImageAsync { [weak self](fullImage) in
                if fullImage != nil {
                    self?.imageView.image = fullImage
                    self?.layoutSubviews()
                }
            }
        }
        self.layoutSubviews()
    }
    
    
    func didEndScroll() {
        if let croppedImage = model.croppedImage {
            imageView.image = croppedImage
        }else{
            model.getImageAsync(){
                image in
                if let image = image {
                    self.imageView.image = image
                }
            }
        }
    }
    
    @IBAction func cropAction(_ sender: Any) {
        
        let cropVc = MTImageCropController.instance
        cropVc.original = model
        cropVc.modalPresentationStyle = .fullScreen
        cropVc.didFinishCropping = { [weak self, cropVc](image) in
            self?.imageView.image = image
            self?.layoutSubviews()
            cropVc.dismiss(animated: true, completion: nil)
        }
        pushCropController?(cropVc)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var xcenter = scrollView.center.x
        var ycenter = scrollView.center.y
        
        xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter
        
        ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter
        imageView.center = CGPoint(x: xcenter, y: ycenter)
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
