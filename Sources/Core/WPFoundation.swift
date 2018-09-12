//
//  WPFoundation.swift
//  Pods
//
//  Created by alex on 2017/7/8.
//
//  old version 0.3.5
//  new version 0.4.0

import Foundation
import UIKit

/// 自定义输出
public func WPFLog<T>(_ message: T, fileName: String = #file, methodName: String =  #function, lineNumber: Int = #line)
{
    #if DEBUG
    let str : String = (fileName as NSString).pathComponents.last!.replacingOccurrences(of: "swift", with: "");
    print("\(Date()) \(str)\(methodName) [\(lineNumber) line] ---------->\n\(message)")
    #endif
}

//MARK: -
public extension NSObject {
    
    class func swapMethod(originSel: Selector, swapSel: Selector) {
        if let originMet: Method = class_getInstanceMethod(self, originSel),
            let swapMet: Method = class_getInstanceMethod(self, swapSel) {
            let added = class_addMethod(self, originSel, method_getImplementation(swapMet), method_getTypeEncoding(swapMet))
            if added == true {
                class_replaceMethod(self, swapSel, method_getImplementation(originMet), method_getTypeEncoding(originMet))
            } else {
                method_exchangeImplementations(originMet, swapMet)
            }
        }
    }
    
    func getMethodList() -> [String] {
        var count: UInt32 = 0
        guard let methodList = class_copyMethodList(type(of: self), &count) else {
            return []
        }
        var mutabList: [String] = []
        for i in 0 ..< count {
            let method = methodList[Int(i)]
            mutabList.append(NSStringFromSelector(method_getName(method)))
            
        }
        return mutabList
    }
    
    func getPropertyList() -> [String] {
        var count: UInt32 = 0
        guard let propertyList = class_copyPropertyList(type(of: self), &count) else {
            return []
        }
        var mutabList: [String] = []
        for i in 0 ..< count {
            if let nstr = NSString.init(utf8String: property_getName(propertyList[Int(i)])) {
                mutabList.append("\(nstr)")
            }
        }
        return mutabList
    }
    
}

//MARK: -
public extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

//MARK: -
public extension String {
    
    /// 字符串长度
    var length: Int {
        return self.count
    }
    
    var md5: String {
        if let data = self.data(using: .utf8, allowLossyConversion: true) {
            
            let message = data.withUnsafeBytes { bytes -> [UInt8] in
                return Array(UnsafeBufferPointer(start: bytes, count: data.count))
            }
            
            let MD5Calculator = MD5(message)
            let MD5Data = MD5Calculator.calculate()
            
            var MD5String = String()
            for c in MD5Data {
                MD5String += String(format: "%02x", c)
            }
            return MD5String
            
        } else {
            return self
        }
    }
    
    /// 截取字符串 from
    /// - Parameter from: 开始位置
    func substring(from: UInt) -> String {
        guard self.length > Int(from) else {
            return ""
        }
        let idxStart = self.index(self.startIndex, offsetBy: Int(from))
        return String(self[idxStart...])
    }
    /// 截取字符串 to
    /// - Parameter to: 结束为止
    func substring(to: UInt) -> String {
        guard self.length >= Int(to) else {
            return self
        }
        let offsetBy: Int = Int(to) - self.length
        let idxEnd = self.index(self.endIndex, offsetBy: offsetBy)
        return String(self[self.startIndex ..< idxEnd ])
    }
    /// 截取字符串 Range
    /// - Parameter range: 截取的区间
    func substring(range: NSRange) -> String {
        
        if let r = Range.init(range) {
            let start = self.index(self.startIndex, offsetBy: r.lowerBound)
            let end = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[start..<end])
        }
        return self
    }
    
    /// 替换字符串
    mutating func replace(range: NSRange, place: String = "****") {
        
        
        if let r = Range.init(range) {
            let start = self.index(self.startIndex, offsetBy: r.lowerBound)
            let end = self.index(self.startIndex, offsetBy: r.upperBound)
            let range = Range(start..<end)
            
            self.replaceSubrange(range, with: place)
        }
    }
    
    
    func contains(_ str: String) -> Bool {
        let nstr: NSString = NSString(string: self)
        return nstr.contains(str)
    }
    
    
}


//MARK: -
public extension UIColor {
    
    /// 16进制
    /// - Parameter sHex: string hex code (eg. "00EEEE")
    convenience init(sHex: String) {
        var str: String = sHex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if str.hasPrefix("#") {
            let sIndex = str.index(str.startIndex, offsetBy: 1)
            str = String(str[sIndex..<str.endIndex])
        }
        
        var r:CUnsignedInt = 255
        var g:CUnsignedInt = 255
        var b:CUnsignedInt = 255
        var a:CUnsignedInt = 255
        
        if str.length == 6 || str.length == 8 {
            
            let strRed = str.substring(range: NSMakeRange(0, 2))
            let strGreen = str.substring(range: NSMakeRange(2, 2))
            let strBlue = str.substring(range: NSMakeRange(4, 2))
            
            Scanner(string: strRed).scanHexInt32(&r)
            Scanner(string: strGreen).scanHexInt32(&g)
            Scanner(string: strBlue).scanHexInt32(&b)
            
            if str.length > 6 {
                let strAlpha = str.substring(range: NSMakeRange(6, 2))
                Scanner(string: strAlpha).scanHexInt32(&a)
            }
        }
        
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(a)/255.0)
    }
    
    /// Init color with hex code
    /// - Parameter iHex: int hex code (eg. 0x33ff99)
    convenience init(iHex: Int64) {
        guard iHex <= 0xffffff,
            iHex >= 0x000000 else {
                self.init(red: 1, green: 1, blue: 1, alpha: 1)
                return
        }
        
        let fRed: CGFloat = CGFloat((iHex & 0xff0000) >> 16)
        let fGreen: CGFloat = CGFloat((iHex & 0xff00) >> 8)
        let fBlue: CGFloat = CGFloat(iHex & 0xff)
        
        self.init(red: fRed/255, green: fGreen/255, blue: fBlue/255, alpha: 1.0)
    }
    
    
    /// Init color with RGBA 0~255
    ///
    /// - Parameters:
    ///   - r: red 0~255
    ///   - g: green 0~255
    ///   - b: blue 0~255
    ///   - a: alpha 0~100
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a/100)
    }
    
    /// Init color with RGB 0~255
    ///
    /// - Parameters:
    ///   - r: red 0~255
    ///   - g: green 0~255
    ///   - b: blue 0~255
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(r: r, g: g, b: b, a: 100)
    }
    
}

//MARK: -
public extension Dictionary {
    func paraStr() -> String {
        var str = ""
        for (key, value) in self {
            str += "&\(key)=\(value)"
        }
        return str.substring(from: 1)
    }
}

//MARK: -
public extension UIImage {
    
    public static func image(withColor color: UIColor, _ rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.screenS)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
    
    public func resetSize(withSeize size: CGSize = CGSize(width: 500, height: 500)) -> UIImage? {
        let sourceImage = self
        let imageSize = sourceImage.size
        let orginWidth = imageSize.width
        let orginHeight = imageSize.height
        let targetWidth = size.width
        let targetHeight = size.height
        var scaleFactor: CGFloat = 0.0
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var point = CGPoint.zero
        
        if __CGSizeEqualToSize(imageSize, size) == false {
            let widthFactor = targetWidth / orginWidth
            let heightFactor = targetHeight / orginHeight
            if widthFactor > heightFactor {
                scaleFactor = widthFactor
            } else {
                scaleFactor = heightFactor
            }
            
            scaledWidth = orginWidth * scaleFactor
            scaledHeight = orginHeight * scaleFactor
            
            if widthFactor > heightFactor {
                point.y = (targetHeight - scaledHeight) * 0.5
            } else {
                point.x = (targetWidth - scaledWidth) * 0.5
            }
        }
        
        UIGraphicsBeginImageContext(size)
        var rect = CGRect.zero
        rect.origin = point
        rect.size.width = scaledWidth
        rect.size.height = scaledHeight
        sourceImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

//MARK: -
public extension Bundle {
    
    var bundleName: String {
        guard let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String else { return "not found" }
        return name
    }
    
    var bundleID: String {
        guard let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else { return "none" }
        return bundleID
    }
    
    var bundleVersion: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "1.0" }
        return version
    }
    
    var bundleLaunchImageName: String {
        guard let info = Bundle.main.infoDictionary,
            let assets: [[String:String]] = info["UILaunchImages"] as? [[String : String]] else {
                return ""
        }
        
        let sSize = UIScreen.main.bounds.size
        print(sSize)
        
        var sOrientation = ""
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight :
            sOrientation = "Landscape"
        case .portrait, .portraitUpsideDown :
            sOrientation = "Portrait"
        default:
            sOrientation = ""
        }
        
        for asset in assets {
            let size: CGSize = CGSizeFromString(asset["UILaunchImageSize"] ?? "{0, 0}")
            let orientation = asset["UILaunchImageOrientation"] ?? ""
            if size == sSize && orientation == sOrientation {
                return asset["UILaunchImageName"] ?? ""
            }
            
        }
        return ""
    }
}
//MARK: -
public extension UINavigationBar {
    public class func initializeOneMethod() {
        DispatchQueue.once(token: "Update_UINavigationBar_Layout_Margin") {
            self.swapMethod(originSel: #selector(layoutSubviews), swapSel: #selector(wpfLayoutSubviews))
        }
    }
    
    @objc func wpfLayoutSubviews() {
        self.wpfLayoutSubviews()
        
        // Solve the problem that left margin is too wide
        if #available(iOS 11.0, *) {
            self.layoutMargins = UIEdgeInsets.zero
            let space: CGFloat = 8
            for subview in self.subviews {
                if NSStringFromClass(type(of: subview)).contains("ContentView") {
                    subview.layoutMargins = UIEdgeInsets(top: 0, left: space, bottom: 0, right: space)
                }
            }
        }
        
    }
}



//MARK: -
public extension UIView {
    var kWidth: CGFloat {
        get {
            return frame.size.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var kHeight: CGFloat {
        get {
            return frame.size.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    var kLeft: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var kRight: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
        set {
            frame.origin.x = newValue - frame.size.width
        }
    }
    
    var kTop: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var kBottom: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
        set {
            frame.origin.y = newValue - frame.size.height
        }
    }
    
    var kSize: CGSize {
        return frame.size
    }
    
    var kOrigin: CGPoint {
        return frame.origin
    }
    
}

//MARK: -
public extension CGRect {
    var kLeft: CGFloat {
        get {
            return origin.x
        }
        set {
            self.origin.x = newValue
        }
    }
    
    var kRight: CGFloat {
        get {
            return origin.x + size.width
        }
        set {
            self.origin.x = newValue - size.width
        }
    }
    
    var kTop: CGFloat {
        get {
            return origin.y
        }
        set {
            self.origin.y = newValue
        }
    }
    
    var kBottom: CGFloat {
        get {
            return origin.y + size.height
        }
        set {
            self.origin.y = newValue - size.height
        }
    }
    
}

//MARK: -
public extension UIScreen {
    /// 屏幕计算尺寸
    static var screenS: CGFloat {
        get {
            return UIScreen.main.scale
        }
    }
    static var screenW: CGFloat {
        get {
            return UIScreen.main.bounds.width
        }
    }
    
    static var screenH: CGFloat {
        get {
            return UIScreen.main.bounds.height
        }
    }
    static var screenRW: CGFloat {
        get {
            return UIScreen.main.scale * UIScreen.main.bounds.width
        }
    }
    
    static var screenRH: CGFloat {
        get {
            return UIScreen.main.scale * UIScreen.main.bounds.height
        }
    }
    
    static var screenRS: CGFloat {
        get {
            return UIScreen.main.scale / 2
        }
    }
}


//MARK: -
public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4S"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5C"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5S"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6S"
        case "iPhone8,2":                               return "iPhone 6S Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone9,1":                               return "iPhone 7"
        case "iPhone9,2":                               return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

//MARK: -
public extension Date {
    public func userFormatter(_ format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

//MARK: -
public extension DispatchQueue {
    private static var onceTracker = [String]()
    
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}




//MARK: - MD5 method, it comes from Onevcat https://github.com/onevcat/
protocol HashProtocol {
    var message: Array<UInt8> { get }
    
    /** Common part for hash calculation. Prepare header data. */
    func prepare(_ len: Int) -> Array<UInt8>
}

extension HashProtocol {
    
    func prepare(_ len: Int) -> Array<UInt8> {
        var tmpMessage = message
        
        // Step 1. Append Padding Bits
        tmpMessage.append(0x80) // append one bit (UInt8 with one bit) to message
        
        // append "0" bit until message length in bits ≡ 448 (mod 512)
        var msgLength = tmpMessage.count
        var counter = 0
        
        while msgLength % len != (len - 8) {
            counter += 1
            msgLength += 1
        }
        
        tmpMessage += Array<UInt8>(repeating: 0, count: counter)
        return tmpMessage
    }
}

func toUInt32Array(_ slice: ArraySlice<UInt8>) -> Array<UInt32> {
    var result = Array<UInt32>()
    result.reserveCapacity(16)
    
    for idx in stride(from: slice.startIndex, to: slice.endIndex, by: MemoryLayout<UInt32>.size) {
        let d0 = UInt32(slice[idx.advanced(by: 3)]) << 24
        let d1 = UInt32(slice[idx.advanced(by: 2)]) << 16
        let d2 = UInt32(slice[idx.advanced(by: 1)]) << 8
        let d3 = UInt32(slice[idx])
        let val: UInt32 = d0 | d1 | d2 | d3
        
        result.append(val)
    }
    return result
}

struct BytesIterator: IteratorProtocol {
    
    let chunkSize: Int
    let data: [UInt8]
    
    init(chunkSize: Int, data: [UInt8]) {
        self.chunkSize = chunkSize
        self.data = data
    }
    
    var offset = 0
    
    mutating func next() -> ArraySlice<UInt8>? {
        let end = min(chunkSize, data.count - offset)
        let result = data[offset..<offset + end]
        offset += result.count
        return result.count > 0 ? result : nil
    }
}

struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]
    
    func makeIterator() -> BytesIterator {
        return BytesIterator(chunkSize: chunkSize, data: data)
    }
}

func rotateLeft(_ value: UInt32, bits: UInt32) -> UInt32 {
    return ((value << bits) & 0xFFFFFFFF) | (value >> (32 - bits))
}

extension Int {
    /** Array of bytes with optional padding (little-endian) */
    func bytes(_ totalBytes: Int = MemoryLayout<Int>.size) -> [UInt8] {
        return arrayOfBytes(self, length: totalBytes)
    }
}

/** array of bytes, little-endian representation */
func arrayOfBytes<T>(_ value: T, length: Int? = nil) -> [UInt8] {
    let totalBytes = length ?? (MemoryLayout<T>.size * 8)
    
    let valuePointer = UnsafeMutablePointer<T>.allocate(capacity: 1)
    valuePointer.pointee = value
    
    let bytes = valuePointer.withMemoryRebound(to: UInt8.self, capacity: totalBytes) { (bytesPointer) -> [UInt8] in
        var bytes = [UInt8](repeating: 0, count: totalBytes)
        for j in 0..<min(MemoryLayout<T>.size, totalBytes) {
            bytes[totalBytes - 1 - j] = (bytesPointer + j).pointee
        }
        return bytes
    }
    
    valuePointer.deinitialize(count: 1)
    valuePointer.deallocate()
    
    return bytes
}


class MD5: HashProtocol {
    
    static let size = 16 // 128 / 8
    let message: [UInt8]
    
    init (_ message: [UInt8]) {
        self.message = message
    }
    
    /** specifies the per-round shift amounts */
    private let shifts: [UInt32] = [7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
                                    5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20,
                                    4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
                                    6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21]
    
    /** binary integer part of the sines of integers (Radians) */
    private let sines: [UInt32] = [0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
                                   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
                                   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
                                   0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
                                   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
                                   0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
                                   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
                                   0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
                                   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
                                   0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
                                   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x4881d05,
                                   0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
                                   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
                                   0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
                                   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
                                   0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391]
    
    private let hashes: [UInt32] = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476]
    
    func calculate() -> [UInt8] {
        var tmpMessage = prepare(64)
        tmpMessage.reserveCapacity(tmpMessage.count + 4)
        
        // hash values
        var hh = hashes
        
        // Step 2. Append Length a 64-bit representation of lengthInBits
        let lengthInBits = (message.count * 8)
        let lengthBytes = lengthInBits.bytes(64 / 8)
        tmpMessage += lengthBytes.reversed()
        
        // Process the message in successive 512-bit chunks:
        let chunkSizeBytes = 512 / 8 // 64
        
        for chunk in BytesSequence(chunkSize: chunkSizeBytes, data: tmpMessage) {
            // break chunk into sixteen 32-bit words M[j], 0 ≤ j ≤ 15
            var M = toUInt32Array(chunk)
            assert(M.count == 16, "Invalid array")
            
            // Initialize hash value for this chunk:
            var A: UInt32 = hh[0]
            var B: UInt32 = hh[1]
            var C: UInt32 = hh[2]
            var D: UInt32 = hh[3]
            
            var dTemp: UInt32 = 0
            
            // Main loop
            for j in 0 ..< sines.count {
                var g = 0
                var F: UInt32 = 0
                
                switch j {
                case 0...15:
                    F = (B & C) | ((~B) & D)
                    g = j
                    break
                case 16...31:
                    F = (D & B) | (~D & C)
                    g = (5 * j + 1) % 16
                    break
                case 32...47:
                    F = B ^ C ^ D
                    g = (3 * j + 5) % 16
                    break
                case 48...63:
                    F = C ^ (B | (~D))
                    g = (7 * j) % 16
                    break
                default:
                    break
                }
                dTemp = D
                D = C
                C = B
                B = B &+ rotateLeft((A &+ F &+ sines[j] &+ M[g]), bits: shifts[j])
                A = dTemp
            }
            
            hh[0] = hh[0] &+ A
            hh[1] = hh[1] &+ B
            hh[2] = hh[2] &+ C
            hh[3] = hh[3] &+ D
        }
        
        var result = [UInt8]()
        result.reserveCapacity(hh.count / 4)
        
        hh.forEach {
            let itemLE = $0.littleEndian
            let r1 = UInt8(itemLE & 0xff)
            let r2 = UInt8((itemLE >> 8) & 0xff)
            let r3 = UInt8((itemLE >> 16) & 0xff)
            let r4 = UInt8((itemLE >> 24) & 0xff)
            result += [r1, r2, r3, r4]
        }
        return result
    }
}

