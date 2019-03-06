//
//  UIFacilities.swift
//  TemplateApp
//
//  Created by Zhengqian Kuang on 2018-10-27.
//  Copyright © 2018 JandJ. All rights reserved.
//

import UIKit

public class UIFacilities: NSObject {
    
    static let activityIndicatorTag = 0x5A2D79D1
    static let activityIndicatorImageViewTag = 0xC2611823
    static let popUpActionViewsTag = 0x37E3C8EE
    
    
    // MARK: - Auto-layout
    
    public class func setAutoLayoutConstraints(subview: UIView?, superview: UIView?, margin: (top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) = (0, 0, 0, 0)) {
        guard (subview != nil) && (superview != nil) else {
            return
        }
        
        subview!.translatesAutoresizingMaskIntoConstraints = false
        
        // subview!.topAnchor.constraint(equalTo: superview!.topAnchor, constant: margin.top).isActive = true
        // subview!.trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: margin.right).isActive = true
        // subview!.bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: margin.bottom).isActive = true
        // subview!.leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: margin.left).isActive = true
        NSLayoutConstraint.activate([
            subview!.topAnchor.constraint(equalTo: superview!.topAnchor, constant: margin.top),
            subview!.trailingAnchor.constraint(equalTo: superview!.trailingAnchor, constant: margin.right),
            subview!.bottomAnchor.constraint(equalTo: superview!.bottomAnchor, constant: margin.bottom),
            subview!.leadingAnchor.constraint(equalTo: superview!.leadingAnchor, constant: margin.left)
            ])
        
        superview!.layoutIfNeeded()
    }
    
    
    // MARK: - Orientation
    
    public static var lockedOrientation: UIInterfaceOrientationMask = .all
    static var lockOrientationCounter = 0
    
    public class func lockUpOrientation(orientation: UIInterfaceOrientationMask? = nil) {
        if (orientation != nil) && (lockOrientationCounter == 0) {
            lockedOrientation = orientation!
        }
        else {
            switch UIApplication.shared.statusBarOrientation {
            case .portrait:
                lockedOrientation = .portrait
                
            case .portraitUpsideDown:
                lockedOrientation = .portraitUpsideDown
                
            case .landscapeLeft:
                lockedOrientation = .landscapeLeft
                
            case .landscapeRight:
                lockedOrientation = .landscapeRight
                
            default:
                lockedOrientation = .all
                break
            }
        }
        lockOrientationCounter += 1
    }

    public class func unlockOrientation() {
        if lockOrientationCounter > 0 {
            lockOrientationCounter -= 1
        }
        if lockOrientationCounter == 0 {
            lockedOrientation = .all
        }
    }
    
    public class func forceOrientation(orientation: UIInterfaceOrientation) {
        let value = orientation.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    
    // MARK: - View
    
    public enum MessageBubbleCaretPosition {
        case undefined, top, bottom, left, right
    }
    
    public enum LayoutStyle {
        case horizontal, vertical
        case noborder, bordered
    }
    
    public class func createActionsView(captions: Array<String>, backgroundColor: UIColor?, textColor: UIColor?, font: UIFont?, h_margin: CGFloat, v_margin: CGFloat, styles: Array<LayoutStyle>) -> (UIView?, Array<UIView>) {
        
        guard captions.count > 0 else {
            return (nil, [])
        }
        
        let tag_for_label = 12
        // let tag_for_button = 2
        
        let view = UIView()
        var arrActionViews: Array<UIView> = []
        
        var spreadStyle: LayoutStyle = .horizontal
        var bordered: Bool = false
        for style in styles {
            switch style {
            case .vertical:
                spreadStyle = .vertical
                break
                
            case .bordered:
                bordered = true
                break
                
            default:
                break
            }
        }
        
        var totalWidth: CGFloat = 0.0
        var totalHeight: CGFloat = 0.0
        
        let backgroundColor = backgroundColor ?? UIColor.black
        let textColor = textColor ?? UIColor.white
        
        view.backgroundColor = textColor
        
        if bordered {
            view.setBorder(borderWidth: 1, borderColor: textColor, cornerRadius: 12)
        }
        else {
            view.makeRoundCorner(cornerRadius: 12)
        }
        
        var h_margin = h_margin
        if h_margin < 0.1 {
            h_margin = 12.0
        }
        var v_margin = v_margin
        if v_margin < 0.1 {
            v_margin = 8.0
        }
        
        for caption in captions {
            let label = UILabel()
            label.tag = tag_for_label
            label.backgroundColor = UIColor.clear
            label.textColor = textColor
            if font != nil {
                label.font = font!
            }
            else {
                label.font = label.font.withSize(13)
            }
            label.textAlignment = .center
            label.text = caption
            label.sizeToFit()
            
            let frameView = UIView(frame: CGRect(x: 0, y: 0, width: label.frame.width + 2 * h_margin, height: label.frame.height + 2 * v_margin))
            frameView.tag = popUpActionViewsTag
            frameView.backgroundColor = backgroundColor
            frameView.addSubview(label)
            label.frame = CGRect(x: h_margin, y: v_margin, width: label.frame.width, height: label.frame.height)
            
            view.addSubview(frameView)
            
            var frame = frameView.frame
            if spreadStyle == .horizontal {
                if totalHeight < frameView.frame.height {
                    totalHeight = frameView.frame.height
                }
                
                if arrActionViews.count > 0 {
                    totalWidth += 1.0
                }
                frame.origin.x = totalWidth
                frameView.frame = frame
                totalWidth += frameView.frame.width
                var frame = view.frame
                frame.size.width = totalWidth
                frame.size.height = totalHeight
                view.frame = frame
            }
            else { // .vertical
                if totalWidth < frameView.frame.width {
                    totalWidth = frameView.frame.width
                }
                
                if arrActionViews.count > 0 {
                    totalHeight += 1.0
                }
                frame.origin.y = totalHeight
                frameView.frame = frame
                totalHeight += frameView.frame.height
                var frame = view.frame
                frame.size.width = totalWidth
                frame.size.height = totalHeight
                view.frame = frame
            }
            
            arrActionViews.append(frameView)
        }
        
        if spreadStyle == .vertical {
            for frameView in arrActionViews {
                var frame = frameView.frame
                frame.size.width = totalWidth
                frameView.frame = frame
                
                for subview in frameView.subviews {
                    guard (subview.tag == tag_for_label) && (subview is UILabel) else {
                        continue
                    }
                    
                    var frame = subview.frame
                    frame.origin.x = 0
                    frame.size.width = totalWidth
                    subview.frame = frame
                }
            }
        }
        
        return (view, arrActionViews)
    }

}
