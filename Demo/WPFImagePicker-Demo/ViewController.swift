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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }

    
    func btnClick() {
        WPFImagePicker.imagePicker.start(withPresenting: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }


}



/*
 1、获取权限
 2、添加监听
 3、获取资源
 4、解析图片
 5、展示
 
 */

