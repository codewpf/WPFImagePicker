//
//  WPFImagePicker.swift
//  WPFImagePicker
//
//  Created by alex on 2017/9/22.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Photos

typealias WPFIPVoidBlock = () -> Void

public class WPFImagePicker: NSObject {
    
    public static let imagePicker: WPFImagePicker = WPFImagePicker()

    /// The list view controller cell height
    public var ipListCellHeight: CGFloat = 57
    /// The max of the selecteds
    public var ipMaxSeleted: Int = 9
    
    /// The view controller that presented this view controller
    fileprivate var privatePresentingVC: UIViewController?
    public var presentingVC: UIViewController? {
        get {
            return self.privatePresentingVC
        }
    }
    public override init() {
        super.init()
    }
    
    public func start(withPresenting presenting: UIViewController) {
        self.privatePresentingVC = presenting
        self.verifyPhotosAuthorizationStatus()
    }
    
}

//MARK: - Photos Authorization
extension WPFImagePicker {
    
    /// verify photos authorization
    func verifyPhotosAuthorizationStatus(_ status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()) {
        switch status {
        case .notDetermined:
            self.authorizationRequest()
        case .authorized:
            self.authorizationAuthorized()
        case .denied, .restricted:
            self.authorizationDenied()
        }
        
    }
    /// authorization request
    func authorizationRequest() {
        PHPhotoLibrary.requestAuthorization { (status) in
            self.verifyPhotosAuthorizationStatus(status)
        }
    }
    
    /// authorization have authorized
    func authorizationAuthorized() {
        let list = WPFIPListVC()
        let nav = UINavigationController(rootViewController: list)
        
        if let collection = WPFIPManager.manager.fetchUserLibrary() {
            let assets =  PHAsset.fetchAssets(in: collection, options: nil)
            let grid = WPFIPGridVC(assets)
            grid.navigationItem.title = collection.localizedTitle
            nav.pushViewController(grid, animated: false)
        }
        
        self.privatePresentingVC!.showDetailViewController(nav, sender: nav)
    }
    /// authorization have denied
    func authorizationDenied() {
        
        let denied = WPFIPDeniedVC()
        let nav = UINavigationController(rootViewController: denied)
        
        self.privatePresentingVC!.showDetailViewController(nav, sender: nil)
        
    }

}




struct WPFIPConstants {
    struct ConstantKeys {
        let imagePickerDeniedText  = "WPFImagePickerAuthorizationDeniedText"
        
        let imagePickerListVCTitle = "WPFImagePickerListVCTitle"
        
        let imagePickerGridVCPreviewBbiTitle = "WPFImagePickerGridVCPreviewBbiTitle"
        let imagePickerGridVCFullImageBbiTitle = "WPFImagePickerGridVCFullImageBbiTitle"
        let imagePickerGridVCSendBbiTitle = "WPFImagePickerGridVCSendBbiTitle"
        let imagePickerGridVCEditBbiTitle = "WPFImagePickerGridVCEditBbiTitle"

        let imagePickerMAXSlectedAlertMessage = "WPFImagePickerMAXSlectedAlertMessage"
        let imagePickerMAXSlectedAlertBtnTitle = "WPFImagePickerMAXSlectedAlertBtnTitle"
    }
    static let keys: ConstantKeys = ConstantKeys()
}

extension Bundle {
    class func wpf() -> Bundle? {
        guard let path = Bundle.main.path(forResource: "WPFImagePicker", ofType: "bundle"),
            let bundle = Bundle(path: path) else {
                return nil
        }
        return bundle
    }
    
    func localizeString(forkey key: String) -> String {
        return self.localizedString(forKey: key, value: nil, table: "Localizable")
    }

    class func localizeString(forkey key: String) -> String {
        guard var language = NSLocale.preferredLanguages.first else {
            return "did not have except language "
        }
        if language.hasPrefix("en") {
            language = "en"
        } else if language.hasPrefix("zh") {
            if language.range(of: "Hans") != nil {
                language = "zh-Hans"
            } else {
                language = "zh-Hant"
            }
        } else {
            language = "en"
        }
        
        guard let path = self.wpf()?.path(forResource: language, ofType: "lproj") ,
               let bundle = Bundle(path: path) else {
            return "did not have except lproj files"
        }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}


