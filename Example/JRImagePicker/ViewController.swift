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
        let vc = MTPickerViewController.instance
        vc.modalPresentationStyle = .fullScreen
        vc.pickerMaxCount = 1
        vc.imageIsEdit = false
        present(vc, animated: true, completion: nil)
        
    }
    
}

