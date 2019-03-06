//
//  Extensions.swift
//  TemplateApp
//
//  Created by John Kuang on 2018-11-20.
//  Copyright © 2018 JandJ. All rights reserved.
//

import UIKit

public extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

// Dictionary
// let combinedDict = dict1.merging(dict2) { $1 }

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

// https://medium.com/swift2go/swift-how-to-convert-html-using-nsattributedstring-8c6ffeb7046f
public extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    var htmlAttributed: (NSAttributedString?, NSDictionary?) {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return (nil, nil)
            }
            
            var dict:NSDictionary?
            dict = NSMutableDictionary()
            
            return try (NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: &dict), dict)
        } catch {
            print("error: ", error)
            return (nil, nil)
        }
    }
    
    func htmlAttributed(using font: UIFont, color: UIColor) -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(font.pointSize)pt !important;" +
                "color: #\(color.hexString!) !important;" +
                "font-family: \(font.familyName), Helvetica !important;" +
            "}</style> \(self)"
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func htmlAttributed(family: String?, size: CGFloat, color: UIColor) -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-size: \(size)pt !important;" +
                "color: #\(color.hexString!) !important;" +
                "font-family: \(family ?? "Helvetica"), Helvetica !important;" +
            "}</style> \(self)"
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func image(size: CGSize, fontSize: CGFloat) -> UIImage? {
        // https://stackoverflow.com/questions/38809425/convert-apple-emoji-string-to-uiimage/38809531#38809531
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(CGRect(origin: .zero, size: size))
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


// https://medium.com/swift2go/swift-how-to-convert-html-using-nsattributedstring-8c6ffeb7046f
public extension UIColor {
    
    var hexString:String? {
        if let components = self.cgColor.components {
            let r = components[0]
            let g = components[1]
            let b = components[2]
            return  String(format: "%02X%02X%02X", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255))
        }
        return nil
    }
    
    // e.g. "#EEEEEE"
    class func color(withHexColorCode hexColorCode: NSString?) -> UIColor? {
        guard hexColorCode != nil else {
            return nil
        }
        
        var sHexColorCode = String("\(hexColorCode!)")
        sHexColorCode = sHexColorCode.trimmingCharacters(in: CharacterSet.whitespaces)
        guard sHexColorCode.hasPrefix("#") && (sHexColorCode.count == 7) else {
            return nil
        }
        let red = CGFloat(UInt(String(sHexColorCode.dropFirst(1).prefix(2)), radix: 16) ?? 0)
        let green = CGFloat(UInt(String(sHexColorCode.dropFirst(3).prefix(2)), radix: 16) ?? 0)
        let blue = CGFloat(UInt(String(sHexColorCode.suffix(2)), radix: 16) ?? 0)
        let color = UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1.0)
        
        return color
    }
    
    class func defaultButtonTitleColor() -> UIColor {
        return color(withHexColorCode: "#007AFF")! // 7A=122
    }

}


public extension UIFont {
    func bold() -> UIFont? {
        var fontName = "\(self.fontName)"
        
        if fontName.hasSuffix("-Bold") {
            return self
        }
        
        if fontName.hasSuffix("-Regular") {
            fontName = fontName.replacingOccurrences(of: "-Regular", with: "-Bold")
        }
        else {
            fontName += "-Bold"
        }
        
        return UIFont(name: fontName, size: self.pointSize)
    }
    
    func unbold() -> UIFont? {
        var fontName = "\(self.fontName)"
        
        if fontName.hasSuffix("-Regular") {
            return self
        }
        
        if fontName.hasSuffix("-Bold") {
            fontName = String(fontName.dropLast(5))
        }
        
        return UIFont(name: fontName, size: self.pointSize)
    }
}


public extension UIImage {
    
    class func image(from view: UIView?) -> UIImage? {
        guard view != nil else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(view!.bounds.size, false, 0)
        view!.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func save(to path: String) {
        let imageData = self.pngData()
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(path)
        try! imageData?.write(to: imageURL)
    }
    
    class func navigationBackImage() -> UIImage? {
        let buttonHeight: CGFloat = 30
        let imageWidth: CGFloat = 15
        let imageHeight: CGFloat = 24
        let space: CGFloat = 4
        let horizontalMargin: CGFloat = 4
        
        let imageViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        imageViewContainer.backgroundColor = UIColor.clear
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageViewContainer.frame.width, height: imageViewContainer.frame.height))
        imageView.backgroundColor = UIColor.clear
        imageViewContainer.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "backArrow_buttontitlecolor_160x256.png")
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.defaultButtonTitleColor()
        label.textAlignment = .center
        label.text = "Back"
        label.sizeToFit()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 2 * horizontalMargin + imageViewContainer.frame.width + space + label.frame.width, height: buttonHeight))
        view.backgroundColor = UIColor.clear
        view.addSubview(imageViewContainer)
        view.addSubview(label)
        
        var frame = imageViewContainer.frame
        frame.origin.x = 0
        frame.origin.y = (view.frame.height - imageViewContainer.frame.height) / 2
        imageViewContainer.frame = frame
        
        frame = label.frame
        frame.origin.x = imageViewContainer.frame.origin.x + imageViewContainer.frame.width + space
        frame.origin.y = (view.frame.height - label.frame.height) / 2
        label.frame = frame
        
        return image(from: view)
    }
    
    func scale(to size: CGSize, backgroundColor: UIColor = UIColor.clear) -> UIImage? {
        guard (size.width >= 1) && (size.height >= 1) else {
            return nil
        }
        
        let imageSize = self.size
        guard (imageSize.width >= 1) && (imageSize.height >= 1) else {
            return nil
        }
        
        var scaleSize: CGSize = CGSize(width: size.width, height: size.height)
        if size.width / size.height > imageSize.width / imageSize.height {
            scaleSize.width = imageSize.width / imageSize.height * size.height
        }
        else {
            scaleSize.height = imageSize.height / imageSize.width * size.width
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: scaleSize.width, height: scaleSize.height))
        view.backgroundColor = backgroundColor
        let imageView = UIImageView(frame: view.frame)
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        
        return UIImage.image(from: view)
    }
    
}


public extension UITextView {
    func pickText(at gestureRecognizer: UIGestureRecognizer, textGranularity: UITextGranularity) -> String? {
        
        if !(gestureRecognizer.view === self) {
            return nil
        }
        
        var text: String? = nil
        
        let location = gestureRecognizer.location(in: self)
        let textPosition = self.closestPosition(to: location)
        if textPosition != nil {
            let textRange = self.tokenizer.rangeEnclosingPosition(textPosition!, with: textGranularity, inDirection: UITextDirection.layout(UITextLayoutDirection.right))
            if textRange != nil {
                text = self.text(in: textRange!)
            }
        }
        
        return text
    }
    
    func scrollTo(text: String) {
        if let wholeText = self.text, let range = wholeText.localizedStandardRange(of: text) {
            let viewRange = NSRange(range, in: wholeText)
            self.selectedRange = viewRange // optional
            self.scrollRangeToVisible(viewRange)
        }
    }
}


public extension UIView {
    
    func absolutePosition(to outerView: UIView?) -> CGPoint {
        var absolutePosition = CGPoint(x: 0, y: 0)
        
        if self.superview == nil {
            return absolutePosition
        }
        
        absolutePosition = self.superview!.convert(self.frame.origin, to: outerView ?? UIApplication.shared.keyWindow?.rootViewController?.view)
        
        return absolutePosition
    }
    
    func cell(of tableView: UITableView) -> UITableViewCell? {
        if self is UITableViewCell {
            return (self as! UITableViewCell)
        }
        
        var superview = self.superview
        while (superview != nil) && (!(superview is UITableViewCell)) {
            superview = superview?.superview
        }
        if superview is UITableViewCell {
            return (superview as! UITableViewCell)
        }
        return nil
    }
    
    func showActivityIndicator(style: UIActivityIndicatorView.Style?, position: CGPoint?, andFreezeView freezeView: Bool) {
        if freezeView {
            self.isUserInteractionEnabled = false
        }
        
        var activityIndicator = self.viewWithTag(UIFacilities.activityIndicatorTag) as? UIActivityIndicatorView
        if activityIndicator != nil {
            activityIndicator?.removeFromSuperview()
        }
        activityIndicator = UIActivityIndicatorView(style: style ?? .gray)
        guard activityIndicator != nil else {
            return
        }
        activityIndicator!.tag = UIFacilities.activityIndicatorTag
        
        let centerPosition = position ?? CGPoint(x: (self.frame.size.width - activityIndicator!.frame.size.width) / 2, y: (self.frame.size.height - activityIndicator!.frame.size.height) / 2)
        
        var frame = activityIndicator!.frame
        frame.origin.x = centerPosition.x - (activityIndicator!.frame.size.width / 2)
        frame.origin.y = centerPosition.y - (activityIndicator!.frame.size.height) / 2
        activityIndicator!.frame = frame
        
        self.addSubview(activityIndicator!)
        self.bringSubviewToFront(activityIndicator!)
        
        activityIndicator!.startAnimating()
    }
    
    func removeActivityIndicator(unfreezeView: Bool) {
        if unfreezeView {
            self.isUserInteractionEnabled = true
        }
        
        if let activityIndicator = self.viewWithTag(UIFacilities.activityIndicatorTag) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        
        if let cancelImageView = self.viewWithTag(UIFacilities.activityIndicatorImageViewTag) as? UIImageView {
            cancelImageView.removeFromSuperview()
        }
    }
    
    func makeCaret(caretFrame: CGRect, cornerRadius: CGFloat) {
        guard cornerRadius > -0.001 else {
            return
        }
        
        let bubbleSize = self.frame.size
        var xLeftLine: CGFloat = 0
        var yTopLine: CGFloat = 0
        var xRightLine: CGFloat = bubbleSize.width
        var yBottomeLine: CGFloat = bubbleSize.height
        var caretPosition: UIFacilities.MessageBubbleCaretPosition = .undefined
        if abs(caretFrame.origin.x) < 0.01 {
            caretPosition = .left
            xLeftLine += caretFrame.size.width
        }
        else if abs((caretFrame.origin.x + caretFrame.size.width) - bubbleSize.width) < 0.01 {
            caretPosition = .right
            xRightLine -= caretFrame.size.width
        }
        if abs(caretFrame.origin.y) < 0.01 {
            caretPosition = .top
            yTopLine += caretFrame.size.height
        }
        else if abs((caretFrame.origin.y + caretFrame.size.height) - bubbleSize.height) < 0.01 {
            caretPosition = .bottom
            yBottomeLine -= caretFrame.size.height
        }
        if caretPosition == .undefined {
            print("Caret position unrecognized.")
            return;
        }
        
        let bubblePath: UIBezierPath = UIBezierPath()
        bubblePath.move(to: CGPoint(x: xLeftLine + cornerRadius, y: yTopLine))
        
        if caretPosition == .top {
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x, y: yTopLine))
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x + (caretFrame.size.width / 2), y: 0))
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x + caretFrame.size.width, y: yTopLine))
        }
        bubblePath.addLine(to: CGPoint(x: xRightLine - cornerRadius, y: yTopLine))
        bubblePath.addArc(withCenter: CGPoint(x: xRightLine - cornerRadius, y: yTopLine + cornerRadius), radius: cornerRadius, startAngle: .pi / 2, endAngle: 0, clockwise: true)
        
        if caretPosition == .right {
            bubblePath.addLine(to: CGPoint(x: xRightLine, y: caretFrame.origin.y))
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x + caretFrame.size.width, y: caretFrame.origin.y + (caretFrame.size.height / 2)))
            bubblePath.addLine(to: CGPoint(x: xRightLine, y: caretFrame.origin.y + caretFrame.size.height))
        }
        bubblePath.addLine(to: CGPoint(x: xRightLine, y: yBottomeLine - cornerRadius))
        bubblePath.addArc(withCenter: CGPoint(x: xRightLine - cornerRadius, y: yBottomeLine - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: .pi / 2, clockwise: true)
        
        if caretPosition == .bottom {
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x + caretFrame.size.width, y: yBottomeLine))
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x + (caretFrame.size.width / 2), y: caretFrame.origin.y + caretFrame.size.height))
            bubblePath.addLine(to: CGPoint(x: caretFrame.origin.x, y: yBottomeLine))
        }
        bubblePath.addLine(to: CGPoint(x: xLeftLine + cornerRadius, y: yBottomeLine))
        bubblePath.addArc(withCenter: CGPoint(x: xLeftLine + cornerRadius, y: yBottomeLine - cornerRadius), radius: cornerRadius, startAngle: 3 * .pi / 2, endAngle: .pi, clockwise: true)
        
        if caretPosition == .left {
            bubblePath.addLine(to: CGPoint(x: xLeftLine, y: caretFrame.origin.y + caretFrame.size.height))
            bubblePath.addLine(to: CGPoint(x: 0, y: caretFrame.origin.y + (caretFrame.size.height / 2)))
            bubblePath.addLine(to: CGPoint(x: xLeftLine, y: caretFrame.origin.y))
        }
        bubblePath.addLine(to: CGPoint(x: xLeftLine, y: yTopLine + cornerRadius))
        bubblePath.addArc(withCenter: CGPoint(x: xLeftLine + cornerRadius, y: yTopLine + cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: .pi / 2, clockwise: true)
        bubblePath.close()
        
        let bubbleMaskLayer = CAShapeLayer()
        bubbleMaskLayer.path = bubblePath.cgPath
        
        self.layer.mask = bubbleMaskLayer
    }
    
    func setBorder(borderWidth: CGFloat, borderColor: UIColor?, cornerRadius: CGFloat) {
        self.layer.borderWidth = borderWidth
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        }
        self.makeRoundCorner(cornerRadius: cornerRadius)
    }
    
    func makeRoundCorner(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    func makeRound() {
        let radius = min(self.frame.size.width, self.frame.size.height) / 2
        self.makeRoundCorner(cornerRadius: radius)
    }
    
}


public extension UIViewController {
    
    func alert(withTitle title: String?, message: String?, actions: [String], actionHandler: @escaping (String?) -> (), style: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        for sAction in actions {
            let alertAction = UIAlertAction(title: sAction, style: .default) { (alertAction) in
                actionHandler(alertAction.title)
            }
            alertController.addAction(alertAction)
        }
        self.present(alertController, animated: true, completion: {
            //
        })
    }
    
    func isOnTopOfNavigationStack() -> Bool {
        return (self === self.navigationController?.viewControllers.last)
    }
    
}
