//
//  Extensions.swift
//  MTImagePicker
//
//  Created by Luo on 5/24/16.
//  Copyright © 2016 Luo. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

extension UIScreen {
    var compatibleBounds:CGRect{//iOS7 mainScreen bounds 不随设备旋转
        var rect = self.bounds
        if NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0 {
            let orientation = UIApplication.shared.statusBarOrientation
            if orientation.isLandscape{
                rect.size.width = self.bounds.height
                rect.size.height = self.bounds.width
            }
        }
        return rect
    }
}

func jColor(color: Int)->UIColor {
    
    let redComponent = ((color & 0xFF0000) >> 16)
    let greenComponent = ((color & 0x00FF00) >> 8)
    let blueComponent = (color & 0x0000FF)
    
    return UIColor.init(red: CGFloat.init(Float.init(redComponent) / 255.0), green: CGFloat.init(Float.init(greenComponent) / 255.0), blue: CGFloat.init(Float.init(blueComponent) / 255.0), alpha: 1.0)
}

func JColorConveredImage(color: UIColor, size: CGSize) -> UIImage? {
    if size.width <= 0 || size.height <= 0 {
        return nil
    }else{
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

//extension ALAsset {
//    class func getAssetFromUrlSync(lib:ALAssetsLibrary,url:NSURL) -> ALAsset? {
//        let sema = DispatchSemaphore(value: 0)
//        var result:ALAsset?
//        DispatchQueue.global().async {
//            lib.asset(for: url as URL!, resultBlock: { (asset) in
//                result = asset
//                sema.signal()
//            }, failureBlock: { (error) in
//                sema.signal()
//            })
//        }
//        sema.wait()
//        return result
//    }
//    
//    class func getLib(failure:()->Void) -> ALAssetsLibrary? {
//        let status = ALAssetsLibrary.authorizationStatus()
//        if status == .authorized || status == .notDetermined {
//            return ALAssetsLibrary()
//        } else {
//            failure()
//            return nil
//        }
//    }
//    
//     @nonobjc static let lib:ALAssetsLibrary = ALAssetsLibrary()
//}

extension Int {
    func byteFormat( places:UInt = 2 ) -> String {
        if self < 0 {
            return ""
        }
        else if self == 0 {
            return "0KB"
        }
        else if self < 1024 {
            return "1KB"
        }
        else if self < 1024 * 1024 { //KB
            return "\(self/1024)KB"
        }
        else if self < 1024 * 1024 * 1024 { //MB
            return "\(String(format: "%.\(places)f", Float(self) / 1024 / 1024))MB"
        }
        else {
            return "\(String(format: "%.\(places)f", Float(self) / 1024 / 1024 / 1024))GB"
        }
    }
}

extension Double {
    func timeFormat() -> String {
        let ticks = Int(self)
        let text = String(format: "%d:%02d",ticks/60,ticks%60)
        return text
    }
}

extension UIView {
    func heartbeatsAnimation(duration:Double) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }){
            _ in
            UIView.animate(withDuration: duration, animations: {
                self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }){
                _ in
                UIView.animate(withDuration: duration){
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        }
    }
    
    func addShader(shadowRadius: CGFloat, alpha: CGFloat){
          
          addShader(shadowRadius: shadowRadius, alpha: alpha, size: self.bounds.size)
      }
      
      func addShader(shadowRadius: CGFloat, alpha: CGFloat, size: CGSize){
          self.layer.masksToBounds = false
          self.layer.shadowColor = jColor(color: 0x000000).withAlphaComponent(alpha).cgColor
          self.layer.shadowOffset = CGSize(width: 0, height: 0)
          self.layer.shadowOpacity = 1
          self.layer.shadowRadius = shadowRadius
          
          self.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: size), cornerRadius: self.layer.cornerRadius).cgPath
      }
}

extension String {
    var localized:String {
        return NSLocalizedString(self, comment: "")
    }
}

extension Bundle {
    static func getResourcesBundle() -> Bundle? {
        let bundle = Bundle(for: MTImagePickerController.self)
        guard let resourcesBundleUrl = bundle.url(forResource: "MTImagePicker", withExtension: "bundle") else {
            return Bundle(for: MTImagePickerController.self)
        }
        return Bundle(url: resourcesBundleUrl)
    }
    
    static func getImage(name: String) -> UIImage? {
        let bundle = Bundle(for: MTImagePickerController.self)
        if let url = bundle.url(forResource: "MTImagePicker", withExtension: "bundle"){
            let targetBundle = Bundle(url: url)
            return  UIImage(named: name, in: targetBundle, compatibleWith: nil)
        }
       
        if #available(iOS 13.0, *) {
            return UIImage(named: name, in: bundle, with: nil)
        } else {
            return UIImage(named: name)
        }
    }
}



