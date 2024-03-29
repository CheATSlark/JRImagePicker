//
//  ViewController.swift
//  JRImagePicker
//
//  Created by jruijqx@163.com on 09/15/2020.
//  Copyright (c) 2020 jruijqx@163.com. All rights reserved.
//

import UIKit
import JRImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pickerAction(_ sender: Any) {
        let vc = MTImagePickerController.instance(mediaType: [MTImagePickerMediaType.Video])
        vc.mediaTypes = [MTImagePickerMediaType.Video]
        vc.maxCount = 1
        vc.isCrop = false
//        vc.imagePickerDelegate = self
        vc.pickedMedias = { (media) in
            
        }
        vc.modalPresentationStyle = .fullScreen
      
        
//        let vc = MTPickerViewController.instance
//        vc.modalPresentationStyle = .fullScreen
//        vc.pickerMaxCount = 1
//        vc.imageIsEdit = false
//        vc.selectedShoot = false
//        vc.mediaType = [.Video]
        present(vc, animated: true, completion: nil)
        
    }
    
}

