//
//  ViewController.swift
//  WPFImagePicker-Demo
//
//  Created by alex on 2017/8/18.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos
import WPFImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let btn: UIButton = UIButton(type: .custom)
        btn.frame = CGRect(x: 20, y: 50, width: UIScreen.screenW-40, height: 30)
        btn.setTitle("相册", for: .normal)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.addTarget(self, action: #selector(self.btnClick), for: .touchUpInside)
        self.view.addSubview(btn)
        
//        self.saveImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    
    @objc func btnClick() {
        var conf = WPFIPConfiguration.default
        conf.languge = .simplified
        conf.autoPlayLivePhoto = false
        conf.autoPlayGif = true
        WPFImagePicker.imagePicker.conf = conf
        WPFImagePicker.imagePicker.start(withPresenting: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func saveImage() {
        for _ in 0 ..< 10 {
            let color: UIColor = UIColor(r: CGFloat(Int(arc4random())%255), g: CGFloat(Int(arc4random())%255), b: CGFloat(Int(arc4random())%255))
            let image: UIImage = UIImage.image(withColor: color, CGRect(x: 0, y: 0, width: 500, height: 500))
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.doneSave(image:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    var tempa = 0
    var tempb = 0
    @objc func doneSave(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: AnyObject?) {
        
        if error != nil {
            print("done --- \(tempa)")
            
            tempa = tempa + 1

        } else {
            print("done +++++++ \(tempb)")
            
            tempa = tempb + 1

        }
        
    }

    
    

}



/*
 1、获取权限
 2、添加监听
 3、获取资源
 4、解析图片
 5、展示
 
 */

