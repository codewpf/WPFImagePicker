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
    /// 工具栏高度
    let kToolBarHeight: CGFloat = 45
    
    
    
    private let pTitle: UILabel = {
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width/2, height: 44))
        title.textColor = UIColor.white
        title.font = UIFont.boldSystemFont(ofSize: 17)
        title.textAlignment = .center
        return title
    }()
    var wpfTitle: String? {
        get {
            return self.pTitle.text
        }
        set {
            self.pTitle.text = newValue
            self.pTitle.frame = CGRect(x: 0, y: 0, width: 200, height: self.navigationController?.navigationBar.frame.size.height ?? 44)
            self.navigationItem.titleView = pTitle
            
        }
    }
    
    
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
    
    /// 导航设置
    func navSetting(_ nav: UINavigationBar?) {
        if let nnn = nav {
            let height = UIApplication.shared.statusBarFrame.height + nnn.height
            let image2 = UIImage.image(withColor: UIColor(r: 43, g: 47, b: 51, a: 94), CGRect(x: 0, y: 0, width: 2, height: height))
            nnn.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            nnn.tintColor = UIColor.white
            nnn.setBackgroundImage(image2, for: .default)
            nnn.shadowImage = UIImage()
            nnn.barStyle = .black
        }
        
    }

    
    func systemSetting() {
        self.view.backgroundColor = UIColor.white
        
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
    
    func contentToolBarHeight() -> CGFloat {
        if UIScreen.screenH == 812 {
            return 34 + kToolBarHeight
        } else {
            return kToolBarHeight
        }
    }
    
 
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override var prefersStatusBarHidden: Bool {
        return false
    }

}

//MAKR: -
extension WPFIPBaseVC {
    
    
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















