//
//  MTTakePhotoController.swift
//  JRImagePicker
//
//  Created by 焦瑞洁 on 2020/9/16.
//

import UIKit

class MTTakePhotoController: UIViewController {

    
    @IBOutlet weak var navigationBar: UINavigationBar!
    class var instance:MTTakePhotoController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle:  Bundle(for: MTTakePhotoController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "MTTakePhotoController") as! MTTakePhotoController
            return vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        // Do any additional setup after loading the view.
    }
    
}
