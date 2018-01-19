//
//  WPFIPManager.swift
//  WPFImagePicker
//
//  Created by alex on 2017/8/24.
//  Copyright © 2017年 alex. All rights reserved.
//

import UIKit
import Foundation
import Photos

class WPFIPManager {
    var listModel: WPFIPListModel = WPFIPListModel()
    
    static let manager = WPFIPManager()
}

//MARK: - 集合
extension WPFIPManager {
    /// 获取所有照片集合
    func fetchAssetCollection() -> [WPFIPListModel] {
        var result: [PHAssetCollection] = []
        
        let asset: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        asset.enumerateObjects({ (collection, idx, _) in
                result.append(collection)
        })

        let smart: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        smart.enumerateObjects({ (collection, idx, _) in
            if collection.assetCollectionSubtype != .smartAlbumUserLibrary &&
                collection.assetCollectionSubtype != .smartAlbumAllHidden {
                result.append(collection)
            }
        })

        let user: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        user.enumerateObjects({ (collection, _, _) in
            result.append(collection)
        })
        
        
        var listModels: [WPFIPListModel] = []
        for collection in result {
            let assets = PHAsset.fetchAssets(in: collection, options: nil)
            
            let title: String = collection.localizedTitle ?? ""
            let count: Int = assets.count
            let result: PHAssetCollection = collection
            var thumbAsset: WPFIPModel? = nil
            var models: [WPFIPModel] = []
            assets.enumerateObjects({ (asset, _, _) in
                let type: WPFIPAssetType = self.type(for: asset)
                let duration: String = self.duration(for: asset)
                let model = WPFIPModel(asset: asset, type: type, duration: duration, image: nil)
                models.append(model)
            })
            if models.count > 0 {
                thumbAsset = models.last!
            }
            let listModel = WPFIPListModel(title: title, count: count, result: result, thumbAsset: thumbAsset, models: models)
            listModels.append(listModel)
        }
        
        return listModels
    }
    
    /// 获取“相机胶卷”集合
    func fetchUserLibrary() -> WPFIPListModel? {
        var temp: PHAssetCollection? = nil

        let asset: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        asset.enumerateObjects({ (collection, idx, _) in
            temp = collection
        })
        
        guard let coll = temp else {
            return nil
        }
        
        let assets = PHAsset.fetchAssets(in: coll, options: nil)
        
        let title: String = coll.localizedTitle ?? ""
        let count: Int = assets.count
        let result: PHAssetCollection = coll
        var thumbAsset: WPFIPModel? = nil
        var models: [WPFIPModel] = []
        assets.enumerateObjects({ (asset, _, _) in
            let type: WPFIPAssetType = self.type(for: asset)
            let duration: String = self.duration(for: asset)
            let model = WPFIPModel(asset: asset, type: type, duration: duration, image: nil)
            models.append(model)
        })
        if models.count > 0 {
            thumbAsset = models.last!
        }
        let listModel = WPFIPListModel(title: title, count: count, result: result, thumbAsset: thumbAsset, models: models)
        
        return listModel
    }
    
    
    /// 根据“创建时间排序“获取所有照片，暂时不用
    func fetchAsset(_ ascending: Bool = true) {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        let result: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: .image, options: options)
        result.enumerateObjects({ (asset, idx, _) in
            print(asset.value(forKey: "filename") ?? "没有 filename")
        })

    }
    
    
}


//MARK: - 图片
typealias WPFIPImageBlock = (_ result: Bool, _ image: UIImage?, _ info: [AnyHashable: Any]?) -> Void
typealias WPFIPImageDataBlock = (_ result: Bool, _ data: Data, _ info: [AnyHashable: Any]?) -> Void
typealias WPFIPLivePhotoBlock = (_ result: Bool, _ livePhoto: PHLivePhoto, _ info: [AnyHashable: Any]?) -> Void
typealias WPFIPVideoBlock = (_ result: Bool, _ item:AVPlayerItem, _ info: [AnyHashable: Any]?) -> Void

extension WPFIPManager {
    
    class func testrequestImage(for asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode = .fast, contentMode: PHImageContentMode = .default, completion: @escaping WPFIPImageBlock) {
        
        let options = PHImageRequestOptions()
        options.resizeMode = resizeMode
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: contentMode, options: options) { (image, info) in
            //            guard
            //                let imageTemp = image,
            //                let infoTemp = info,
            //                infoTemp[PHImageErrorKey] == nil else {
            //                completion(false,UIImage(), [:])
            //                return
            //            }
            completion(true,image,info)
        }
    }

    
    /// 获取图片
    func requestImage(for asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode = .fast, contentMode: PHImageContentMode = .default, completion: @escaping WPFIPImageBlock) {
        
        let options = PHImageRequestOptions()
        options.resizeMode = resizeMode
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: contentMode, options: options) { (image, info) in
//            guard
//                let imageTemp = image,
//                let infoTemp = info,
//                infoTemp[PHImageErrorKey] == nil else {
//                completion(false,UIImage(), [:])
//                return
//            }
            completion(true,image,info)
        }
    }
    
    /// 获取图片 二进制数据
    func requestImageData(for asset: PHAsset, completion: @escaping WPFIPImageDataBlock) {
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, _, info) in
            guard
                let dataTemp = data,
                let infoTemp = info,
                infoTemp[PHImageErrorKey] == nil else {
                    completion(false,Data(), [:])
                    return
            }
            completion(true,dataTemp,info)
        }
        
    }
    
    /// 获取实况图片
    func requestLivePhoto(for asset: PHAsset, completion: @escaping WPFIPLivePhotoBlock) {
        
        let options = PHLivePhotoRequestOptions()
        options.version = .current
        options.deliveryMode = .opportunistic
        
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (livePhoto, info) in
            guard let livePhotoTemp = livePhoto else {
                completion(false, PHLivePhoto(), info)
                return
            }
            completion(true, livePhotoTemp, info)
        }
    }
    
    /// 获取视频
    func requestVideo(for asset: PHAsset, completion: @escaping WPFIPVideoBlock) {
        let optiions = PHVideoRequestOptions()
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: optiions) { (item, info) in
            guard let itemTemp = item else {
                completion(false, item!, info)
                return
            }
            completion(true, itemTemp, info)
        }
    }
    
    
    
}

//MARK: - SupportMethod
extension WPFIPManager {
    /// 获取 元素 资源类型
    func type(for asset: PHAsset) -> WPFIPAssetType {
        switch asset.mediaType {
        case .audio:
            return .audio
        case .video:
            return .video
        case .image:
            if let name = asset.value(forKey: "filename") as? String, name.hasSuffix("GIF") {
                return .gif
            } else if asset.mediaSubtypes == .photoLive {
                return .livePhoto
            } else {
                return .image
            }
        case .unknown:
            return .unknown
        }
    }
    
    /// 获取 元素 时长
    func duration(for asset: PHAsset) -> String {
        guard asset.mediaType == .video else {
            return ""
        }
        
        let duration = Int(asset.duration.rounded())
        if duration < 60 {
            return  "00:\(duration)"
        } else if duration < 3600 {
            let m = duration / 60
            let s = duration % 60
            return "\(m):\(s)"
        } else {
            let h = duration / 3600
            let m = (duration % 3600) / 60
            let s = duration % 60
            return "\(h):\(m):\(s)"
            
        }
    }
    
    
    
}








