//
//  UIColor+hex.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 23.06.2023.
//

import UIKit

extension UIColor {
    func toHex() -> String? {
        guard let components = self.cgColor.components else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        let hexString = String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return hexString
    }
    
    static func colorFromHex(_ hex: String) -> UIColor? {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        guard hexString.count == 6 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension UIColor {
    func withBrightness(_ brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: nil, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
        } else {
            return self
        }
    }
    
    var brightness: CGFloat {
        var brightness: CGFloat = 0.0
        getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
        return brightness
    }
}

