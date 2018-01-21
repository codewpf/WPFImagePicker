//
//  WPFIPConfiguration.swift
//  WPFImagePicker
//
//  Created by alex on 2018/1/17.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit

public struct WPFIPConfiguration {
    
    private static var pDefault: WPFIPConfiguration = WPFIPConfiguration()
    public static var `default`: WPFIPConfiguration {
        get {
            return pDefault
        }
    }
    
    
    /// 最大选择数量,默认为 9
    public var maxSelect: Int = 9
    
    /// 可选择视频最大时长，单位：秒，默认为 120
    public var maxVideoDuration: Int = 120
    
    
    
    /// 是否允许选择原图，默认为 true
    public var canSelectOriginal: Bool = true
    
    /// 是否允许Force Touch功能，默认为 true
    public var canForceTouch: Bool = true
    
    /// 是否允许GIF ForrceTouch，默认为 false；比较消耗资源
    public var canFTGif: Bool = false
    
    /// 是否允许滑动选择（类似系统相册功能），默认为 true
    public var canSlideSelect: Bool = true

    /// 是否从底部依次向上显示图片（同微信样式），否则从上依次向下显示，默认为 true
    public var fromBottom: Bool = true
    
    
    
    /// 导航条颜色，默认为 UIColor(r: 43, g: 47, b: 51, a: 94)
    public var navigationBarColor: UIColor = UIColor(r: 43, g: 47, b: 51, a: 94)
    
    /// 导航标题颜色，默认为 UIColor.white
    public var navigationBarTitleColor: UIColor = UIColor.white
    
    /// 工具栏颜色，默认为
    public var toolBarColor: UIColor = UIColor.white
    
    /// 工具栏 normal 颜色
    public var toolBarNormalColor: UIColor = UIColor.white
    
    /// 工具栏 disable 颜色
    public var toolBarDisableColor: UIColor = UIColor.white
    
    
    
    /// 语言，默认为 .system
    public var languge: WPFIPLanguage = .system
    
    
    
    /// 列表页 Cell 高度，默认为 57
    public var listCellHeight: CGFloat = 57
    
    
    static func resetDefault() {
        self.pDefault.maxSelect = 9
        self.pDefault.maxVideoDuration = 120
        
        self.pDefault.canSelectOriginal = true
        self.pDefault.canForceTouch = true
        self.pDefault.canFTGif = false
        self.pDefault.canSlideSelect = true
        self.pDefault.fromBottom = true
        
        self.pDefault.navigationBarColor = UIColor(r: 43, g: 47, b: 51, a: 94)
        self.pDefault.navigationBarTitleColor = UIColor.white
        self.pDefault.toolBarColor = UIColor.white
        self.pDefault.toolBarNormalColor = UIColor.white
        self.pDefault.toolBarDisableColor = UIColor.white
        
        self.pDefault.languge = .system
        self.pDefault.listCellHeight = 57
    }
    
}










