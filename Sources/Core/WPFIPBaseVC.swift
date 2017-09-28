//
//  WPFIPBaseVC.swift
//  WPFImagePicker
//
//  Created by alex on 2017/9/21.
//  Copyright © 2017年 alex. All rights reserved.
//
//  WPF Base VC

import UIKit
import Photos

public class WPFIPBaseVC: UIViewController {
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.systemSetting()
        
        PHPhotoLibrary.shared().register(self)

    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

//MARK: - Setting
extension WPFIPBaseVC {
    func systemSetting() {
        if #available(iOS 11.0, *) {
            
        } else {
            self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.extendedLayoutIncludesOpaqueBars = false
    }
    
    func contentRect() -> CGRect {
        var rect = CGRect.zero
        if #available(iOS 11.0, *) {
            let edge = self.view.safeAreaInsets
            rect = CGRect(x: 0, y: edge.top, width: UIScreen.screenW, height: UIScreen.screenH-edge.top-edge.bottom)
        } else {
            rect = CGRect(x: 0, y: 0, width: UIScreen.screenW, height: UIScreen.screenH-(self.navigationController?.navigationBar.height ?? 44)-UIApplication.shared.statusBarFrame.height)
        }
        return rect
    }
}

//MARK: - Delegate
extension WPFIPBaseVC: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
}


