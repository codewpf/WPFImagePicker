//
//  WPFIPExtension.swift
//  WPFImagePicker
//
//  Created by alex on 2018/1/19.
//  Copyright © 2018年 alex. All rights reserved.
//

import UIKit

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


extension Data {
    /// 转换成GIF图片
    func toGIF() -> UIImage? {
        let cf = NSData(data: self) as CFData
        
        guard let source = CGImageSourceCreateWithData(cf, nil) else {
            return nil
        }

        let count = CGImageSourceGetCount(source)
        var result: UIImage? = nil

        if count <= 1 {
            result = UIImage(data: self)
        } else {
            var images: [UIImage] = []
            var duration: TimeInterval = 0.0
            for i in 0 ..< count {
                guard let image = CGImageSourceCreateImageAtIndex(source, i, nil) else {
                    continue
                }
                duration += self.duration(at: i, source: source)
                images.append(UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up))
            }
            duration = 1.0 / 10.0 * Double(count)
            result = UIImage.animatedImage(with: images, duration: duration)
        }

        return result
    }
    
    /// 获取GIF内单个图片时间
    func duration(at index: Int, source: CGImageSource) -> TimeInterval {
        var duration = 0.1
        guard let properties = CGImageSourceCopyProperties(source, nil) as? [CFString: Any] else {
            return duration
        }
        guard let gifDictionary = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] else {
            return duration
        }
        if let unclampedDelayTime = gifDictionary[kCGImagePropertyGIFUnclampedDelayTime] as? NSNumber {
            duration = unclampedDelayTime.doubleValue
        } else {
            if let delayTime = gifDictionary[kCGImagePropertyGIFDelayTime] as? NSNumber {
                duration = delayTime.doubleValue
            }
        }
        
        if duration < 0.011 {
            duration = 0.1
        }
        return duration
    }
    
}













