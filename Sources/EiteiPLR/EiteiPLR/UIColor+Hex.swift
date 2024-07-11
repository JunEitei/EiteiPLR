//
//  UIColor+Hex.swift
//  EiteiPLR
//
//  Created by damao on 2024/6/13.
//

// MARK: - UIColor Extension

#if canImport(UIKit)
import UIKit
#endif

extension UIColor {
    // 使用十六进制字符串初始化 UIColor 实例
    convenience init(hex: String) {
        // 去除字符串前后的空白字符，并将字符串转换为大写
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // 如果字符串以 "#" 开头，则移除它
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        // 如果字符串的长度不是 6，则返回默认灰色颜色
        if hexString.count != 6 {
            self.init(white: 0.5, alpha: 1.0)
            return
        }
        
        // 将十六进制字符串转换为 UInt64 类型的整数值
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        // 从整数值中提取红色、绿色和蓝色分量
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        // 使用提取的 RGB 分量初始化 UIColor 实例
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // 返回Eitei主題橙色
    static var eiteiOrange: UIColor {
        return UIColor(hex: "#feb600")
    }
    
    // 返回Eitei主題灰色
    static var eiteiGray: UIColor {
        return UIColor(hex: "#303030")
    }
    
    // 返回Eitei主題背景深灰色
    static var eiteiBackground: UIColor {
        return UIColor(hex: "#303030")
    }
    
    
    // 返回Eitei主題淺灰色
    static var eiteiLightGray: UIColor {
        return UIColor(hex: "#555555")
    }
    
    
    // 返回Eitei主題紅色
    static var eiteiRed: UIColor {
        return UIColor(hex: "#C94640")
    }
    
    // 返回Eitei主題深橙色
    static var eiteiSuperOrange: UIColor {
        return UIColor(hex: "#EF8B3A")
    }
    
    // 返回Eitei主題綠
    static var eiteiGreen: UIColor {
        return UIColor(hex: "#72A637")
    }
    
    // 返回Eitei主題藍
    static var eiteiBlue: UIColor {
        return UIColor(hex: "#489DC9")
    }
    
    // 返回Eitei主題黃色
    static var eiteiYellow: UIColor {
        return UIColor(hex: "#F3B940")
    }
    
    // 返回Eitei主題極淺灰
    static var eiteiExtraLightGray: UIColor {
        return UIColor(hex: "#D3D3D3")
    }
    
    // UIColor 轉換為十六進制字串
    func toHexString(includeAlpha: Bool = true) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        if includeAlpha {
            return String(format: "#%02lX%02lX%02lX%02lX", lroundf(Float(red * 255)), lroundf(Float(green * 255)), lroundf(Float(blue * 255)), lroundf(Float(alpha * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX", lroundf(Float(red * 255)), lroundf(Float(green * 255)), lroundf(Float(blue * 255)))
        }
    }
    
    // 將十六進制字串轉換回 UIColor
    convenience init(hexString: String) {
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        
        var rgba: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgba)
        
        let red = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(rgba & 0x000000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
