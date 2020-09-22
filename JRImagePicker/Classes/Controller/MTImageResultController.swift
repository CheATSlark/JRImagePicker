//
//  MTImageResultController.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/21.
//

import UIKit

class MTImageResultController: UIViewController {
    
    var list: [MTImagePickerPhotosModel] = []
    var resultList: (([MTImagePickerPhotosModel])->Void)?
    
    @IBOutlet weak var collection: UICollectionView!
    
    class var instance:MTImageResultController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTImageResultController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "MTImageResultController") as! MTImageResultController
            return vc
        }
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configRightNavigationbar()
        configLeftNavigationBar()
    }
    
    func configRightNavigationbar(){
        let item = UIBarButtonItem(title: "下一步", style: .done, target: self, action: #selector(nextStep))
        item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], for: .normal)
        self.navigationItem.setRightBarButton(item, animated: false)
    }
    
    func configLeftNavigationBar(){

        let item = UIBarButtonItem(image:Bundle.getImage(name: "navi_back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(goback))
        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 21)
        navigationItem.setLeftBarButton(item, animated: false)
    }
    
    
    @objc
    func nextStep(){
        resultList?(list)
    }
    
    @objc func goback(){
        navigationController?.popViewController(animated: true)
    }
    
    
}

extension MTImageResultController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = list[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageResultClCell
        cell.pushCropController = { [weak self](vc) in
            self?.present(vc, animated: true, completion: nil)
        }
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cell.initWithModel(model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collection.bounds.width, height: collection.bounds.height)
    }
    
    //MARK:UIScrollViewDelegate
    //防止visibleCells出现两个而不是一个，导致.first得到的是未显示的cell
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.perform(#selector(MTImagePickerPreviewController.didEndDecelerating), with: nil, afterDelay: 0)
    }
    
    @objc func didEndDecelerating() {
        let cell = collection.visibleCells.first
        if let imageCell = cell as? ImageResultClCell {
            imageCell.didEndScroll()
        }
    }
}
