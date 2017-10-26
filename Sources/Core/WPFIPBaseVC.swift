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
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
                
        self.navSetting(self.navigationController?.navigationBar)
        
        self.systemSetting()
        
        PHPhotoLibrary.shared().register(self)

    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}


//MARK: - Setting
extension WPFIPBaseVC {
    func navSetting(_ nav: UINavigationBar?) {
        
        let height = UIApplication.shared.statusBarFrame.height + nav!.height
        let image2 = UIImage.image(withColor: UIColor(r: 43, g: 47, b: 51, a: 94), CGRect(x: 0, y: 0, width: 2, height: height))
        nav?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        nav?.tintColor = UIColor.white
        nav?.setBackgroundImage(image2, for: .default)
        nav?.shadowImage = UIImage()
        nav?.barStyle = .black
        
    }

    
    func systemSetting() {
        if #available(iOS 11.0, *) {
            
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func contentInsetTop(_ calculate: Bool = true) -> CGFloat {
        if #available(iOS 11.0, *) , calculate == true {
            let edge = self.view.safeAreaInsets
            return edge.top
        } else {
            return (self.navigationController?.navigationBar.height ?? 44) + UIApplication.shared.statusBarFrame.height
        }
    }
    func contentInsetBottom(_ calculate: Bool = true) -> CGFloat {
        if #available(iOS 11.0, *) , calculate == true {
            let edge = self.view.safeAreaInsets
            return edge.bottom
        } else {
            return 0
        }
    }
    
 
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override var prefersStatusBarHidden: Bool {
        return false
    }

}

//MARK: - Subclass methods
extension WPFIPBaseVC {
    func showMaximumAlert() {
        let alert = UIAlertController(title: nil, message: Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerMAXSlectedAlertMessage), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Bundle.localizeString(forkey: WPFIPConstants.keys.imagePickerMAXSlectedAlertBtnTitle), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Delegate
extension WPFIPBaseVC: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
}

/*
//MARK: - NavigationController
extension WPFIPBaseVC: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    
    
    
}
*/















