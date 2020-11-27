//
//  LimitImageLeadView.swift
//  JRImagePicker
//
//  Created by cyf on 2020/11/24.
//

import UIKit

typealias VisitPartImageCallBack = ()->()

class LimitImageLeadView: UIView {

    var visitPartImageCallBack: VisitPartImageCallBack?
    
    @IBOutlet weak var setLimintBtn: UIButton!
    
    @IBOutlet weak var visitPartImageBtn: UIButton!
    override class func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    /// 打开系统设置
    @IBAction func openSetting(_ sender: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    /// 继续访问部分照片
    @IBAction func visitPartPhotoBtn(_ sender: UIButton) {
        if let call = visitPartImageCallBack {
            call()
        }
    }
    
}
