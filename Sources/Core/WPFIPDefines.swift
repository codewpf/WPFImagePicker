//
//  WPFIPDefines.swift
//  WPFImagePicker
//
//  Created by alex on 2018/1/17.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit

/// 元素 资源类型
public enum WPFIPAssetType: Int {
    /// 未知类型
    case unknown = -1
    /// 图片
    case image = 1
    /// GIF
    case gif = 2
    /// 实况图片
    case livePhoto = 3
    /// 视频
    case video = 4
    /// 音频
    case audio = 5
}


/// 语言 类型
public enum WPFIPLanguage {
    /// 跟随系统，默认s
    case system
    /// 中文简体
    case simplified
    /// 中文繁体
    case traditional
    /// 英文
    case english
    
}


/// 键值
struct WPFIPConstants {
    /// language key
    struct ConstantKeys {
        let imagePickerDeniedText  = "WPFImagePickerAuthorizationDeniedText"
        
        let imagePickerListVCTitle = "WPFImagePickerListVCTitle"
        
        let imagePickerGridVCPreviewBbiTitle = "WPFImagePickerGridVCPreviewBbiTitle"
        let imagePickerGridVCFullImageBbiTitle = "WPFImagePickerGridVCFullImageBbiTitle"
        let imagePickerGridVCSendBbiTitle = "WPFImagePickerGridVCSendBbiTitle"
        let imagePickerGridVCEditBbiTitle = "WPFImagePickerGridVCEditBbiTitle"
        let imagePickerGridVCBackBbiTitle = "WPFImagePickerGridVCBackBbiTitle"
        
        let imagePickerMAXSlectedAlertMessage = "WPFImagePickerMAXSlectedAlertMessage"
        let imagePickerMAXSlectedAlertBtnTitle = "WPFImagePickerMAXSlectedAlertBtnTitle"
    }
    static let keys: ConstantKeys = ConstantKeys()
    
    /// Color
    struct WPFIPColor {
        let themeGreen: UIColor = UIColor(iHex: 0x2FA932)
    }
    static let colors: WPFIPColor = WPFIPColor()

}








