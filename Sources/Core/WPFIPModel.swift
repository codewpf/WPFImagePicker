//
//  WPFIPModel.swift
//  WPFImagePicker
//
//  Created by alex on 2018/1/16.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit
import Photos

struct WPFIPModel {
    
    /// 资源
    let asset: PHAsset
    /// 类型
    let type: WPFIPAssetType
    /// 视频时长
    let duration: String
    /// 图片
    var image: UIImage? = nil

    
}

struct WPFIPListModel {
    
    /// 相册名称
    let title: String
    /// 相册内图片数量
    let count: Int
    /// 未展开的数据集合
    let result: PHAssetCollection
    /// 相册缩略图:List 列表展示使用
    let thumbAsset: WPFIPModel?
    /// 相册内图片资源
    var models: [WPFIPModel]
    /// 被选中 的图片资源
    var selected: [WPFIPModel] = []
    /// 被选中的个数
    var selectedCount: Int {
        get {
            return selected.count
        }
    }

    
    init() {
        self.title = ""
        self.count = 0
        self.result = PHAssetCollection()
        self.thumbAsset = nil
        self.models = []
    }
    
    init(title: String, count: Int, result: PHAssetCollection, thumbAsset: WPFIPModel?, models: [WPFIPModel]) {
        self.title = title
        self.count = count
        self.result = result
        self.thumbAsset = thumbAsset
        self.models = models
    }
    
    
    
    
}








