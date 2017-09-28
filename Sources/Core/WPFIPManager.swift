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

    static let manager = WPFIPManager()
    
    func fetchAssetCollection() -> [PHAssetCollection] {
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
        
        return result
    }
    
    func fetchUserLibrary() -> PHAssetCollection? {
        var result: PHAssetCollection? = nil

        let asset: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        asset.enumerateObjects({ (collection, idx, _) in
            result = collection
        })
        
        return result
    }
    
    
    func fetchAsset(_ ascending: Bool = true) {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        let result: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: .image, options: options)
        result.enumerateObjects({ (asset, idx, _) in
            print(asset.value(forKey: "filename") ?? "没有")
        })

    }
}

