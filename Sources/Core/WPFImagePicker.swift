//
//  WPFImagePicker.swift
//  WPFImagePicker
//
//  Created by alex on 2017/9/22.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos
import ObjectiveC

typealias WPFIPVoidBlock = () -> Void

//MARK: -
public class WPFImagePicker: NSObject {
    
    /// single delegate 单例
    public static let imagePicker: WPFImagePicker = WPFImagePicker()
    
    /// The default configuration 默认配置
    public var conf: WPFIPConfiguration = WPFIPConfiguration.default
    
    /// The view controller that presented this view controller 父控制视图
    fileprivate var privatePresentingVC: UIViewController?
    public var presentingVC: UIViewController? {
        get {
            return self.privatePresentingVC
        }
    }
    public override init() {
        super.init()
    }
    
    /// invoke album 调用相册
    public func start(withPresenting presenting: UIViewController) {
        self.privatePresentingVC = presenting
        self.verifyPhotosAuthorizationStatus()
    }
    
}

//MARK: - Photos Authorization
extension WPFImagePicker {
    
    /// verify photos authorization 验证相册授权状态
    func verifyPhotosAuthorizationStatus(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()) {
        switch status {
        case .notDetermined:
            DispatchQueue.main.async {
                self.authorizationRequest()
            }
        case .authorized:
            DispatchQueue.main.async {
                self.authorizationAuthorized()
            }
        case .denied, .restricted:
            self.authorizationDenied()
        }
        
    }
    /// authorization request 申请授权状态
    func authorizationRequest() {
        PHPhotoLibrary.requestAuthorization { (status) in
            self.verifyPhotosAuthorizationStatus(status)
        }
    }
    
    /// authorization have authorized 授权通过
    func authorizationAuthorized() {
        let list = WPFIPListVC()
        let nav = UINavigationController(rootViewController: list)

        if let listModel = WPFIPManager.manager.fetchUserLibrary() {
            WPFIPManager.manager.listModel = listModel
            let grid = WPFIPGridVC()
            grid.wpfTitle = listModel.title
            nav.pushViewController(grid, animated: false)
        }

        self.privatePresentingVC!.showDetailViewController(nav, sender: nav)
    }
    /// authorization have denied 授权拒绝
    func authorizationDenied() {
        
        let denied = WPFIPDeniedVC()
        let nav = UINavigationController(rootViewController: denied)
        
        self.privatePresentingVC!.showDetailViewController(nav, sender: nil)
        
    }
    
}






