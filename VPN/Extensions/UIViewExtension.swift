//
//  UIViewExtension.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/23/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import UIKit

//MARK: - Round corners
extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}

//MARK: - @IBInspectable
extension UIView {
  
  @IBInspectable
  var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable
  var borderColor: UIColor? {
    get {
      if let color = layer.borderColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.borderColor = color.cgColor
      } else {
        layer.borderColor = nil
      }
    }
  }
  
  @IBInspectable
  var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowRadius = newValue
    }
  }
  
  @IBInspectable
  var shadowOpacity: Float {
    get {
      return layer.shadowOpacity
    }
    set {
      layer.shadowOpacity = newValue
    }
  }
  
  @IBInspectable
  var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }
    set {
      layer.shadowOffset = newValue
    }
  }
  
  @IBInspectable
  var shadowColor: UIColor? {
    get {
      if let color = layer.shadowColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.shadowColor = color.cgColor
      } else {
        layer.shadowColor = nil
      }
    }
  }
    
}

//MARK: - Nib
extension UIView {
    
    // MARK: - Class methods
    class func nib<T: UIView>() -> T {
        var className = NSStringFromClass(self)
        className = className.split{$0 == "."}.map(String.init)[1]
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)![0] as! T
    }
    
    class func nib<T: UIView>(sufix: String) -> T {
        var className = NSStringFromClass(self)
        className = className.split{$0 == "."}.map(String.init)[1]
        className += sufix
        return Bundle.main.loadNibNamed(className, owner: nil, options: nil)![0] as! T
    }
}

//MARK: - Layout
extension UIView {
    
    func equalFrame() {
        guard let superview = superview else { return }
        frame = superview.bounds
    }
    
}

//MARK: - Costemize
extension UIView {
    
    func setupStateButtons(buttons: [UIButton]) {
        buttons.forEach { (button) in
            button.alpha = button.isSelected ? 1 : 0.5
        }
    }
    
}

//MARK: - Animations
extension UIView {
    
    func shake(repeatCount: Float = 1, duaration: Double = 0.5) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = duaration
        animation.repeatCount = repeatCount
        animation.values = [-10.0, 10.0, -10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
}

extension UIImageView {
    
    static func fromGif(frame: CGRect, resourceName: String) -> UIImageView? {
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            print("Gif does not exist at that path")
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
            let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        let gifImageView = UIImageView(frame: frame)
        gifImageView.animationImages = images
        return gifImageView
    }
    
}

