/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

#if os(iOS) || os(macOS)

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
public typealias OSView = NSView
public typealias OSLayoutPriority = NSLayoutConstraint.Priority
#else
public typealias OSView = UIView
public typealias OSLayoutPriority = UILayoutPriority
#endif

public extension OSView {
    
    var highPriority : Float{
        900
    }
    
    var midPriority : Float{
        500
    }
    
    var lowPriority : Float{
        300
    }
    
    static var defaultPriority : Float{
        800
    }
    
    //anchors
    
    func resetConstraints(){
        for constraint in constraints{
            constraint.isActive = false
        }
    }
    
    @discardableResult
    func setAnchors(top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, insets: OSInsets = .zero) -> OSView{
        translatesAutoresizingMaskIntoConstraints = false
        return self.top(top, inset: insets.top)
            .leading(leading, inset: insets.left)
            .trailing(trailing, inset: -insets.right)
            .bottom(bottom, inset: -insets.bottom)
    }

    @discardableResult
    func setAnchors(centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) -> OSView{
        translatesAutoresizingMaskIntoConstraints = false
        return self.centerX(centerX)
            .centerY(centerY)
    }
    
    @discardableResult
    func top(_ top: NSLayoutYAxisAnchor?, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        if let top = top{
            let constraint = topAnchor.constraint(equalTo: top, constant: inset)
            if priority != OSView.defaultPriority{
                constraint.priority = OSLayoutPriority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func leading(_ leading: NSLayoutXAxisAnchor?, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        if let leading = leading{
            let constraint = leadingAnchor.constraint(equalTo: leading, constant: inset)
            if priority != OSView.defaultPriority{
                constraint.priority = OSLayoutPriority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func trailing(_ trailing: NSLayoutXAxisAnchor?, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        if let trailing = trailing{
            let constraint = trailingAnchor.constraint(equalTo: trailing, constant: inset)
            if priority != OSView.defaultPriority{
                constraint.priority = OSLayoutPriority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func bottom(_ bottom: NSLayoutYAxisAnchor?, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        if let bottom = bottom{
            let constraint = bottomAnchor.constraint(equalTo: bottom, constant: inset)
            if priority != OSView.defaultPriority{
                constraint.priority = OSLayoutPriority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func centerX(_ centerX: NSLayoutXAxisAnchor?, priority: Float = defaultPriority) -> OSView{
        if let centerX = centerX{
            let constraint = centerXAnchor.constraint(equalTo: centerX)
            if priority != OSView.defaultPriority{
                constraint.priority = OSLayoutPriority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func centerY(_ centerY: NSLayoutYAxisAnchor?, priority: Float = defaultPriority) -> OSView{
        if let centerY = centerY{
            let constraint = centerYAnchor.constraint(equalTo: centerY)
            if priority != OSView.defaultPriority{
                constraint.priority = OSLayoutPriority(priority)
            }
            constraint.isActive = true
        }
        return self
    }
    
    @discardableResult
    func width(_ width: CGFloat, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        let constraint = widthAnchor.constraint(equalToConstant: width)
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func width(_ anchor: NSLayoutDimension, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        let constraint = widthAnchor.constraint(equalTo: anchor, constant: inset)
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func minWidth(_ anchor: Int, priority: Float = defaultPriority) -> OSView{
        let constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(anchor))
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func width(_ anchor: NSLayoutDimension, percentage: CGFloat, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        let constraint = widthAnchor.constraint(equalTo: anchor, multiplier: percentage, constant: inset)
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func height(_ height: CGFloat, priority: Float = defaultPriority) -> OSView{
        let constraint = heightAnchor.constraint(equalToConstant: height)
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func minHeight(_ anchor: Int, priority: Float = defaultPriority) -> OSView{
        let constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(anchor))
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func height(_ anchor: NSLayoutDimension, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        let constraint = heightAnchor.constraint(equalTo: anchor, constant: inset)
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    @discardableResult
    func height(_ anchor: NSLayoutDimension, percentage: CGFloat, inset: CGFloat = 0, priority: Float = defaultPriority) -> OSView{
        let constraint = heightAnchor.constraint(equalTo: anchor, multiplier: percentage, constant: inset)
        if priority != OSView.defaultPriority{
            constraint.priority = OSLayoutPriority(priority)
        }
        constraint.isActive = true
        return self
    }
    
    func getZeroHeightConstraint() -> NSLayoutConstraint?{
        let constraint = heightAnchor.constraint(equalToConstant: 0.0)
        constraint.priority = OSLayoutPriority(950)
        constraint.isActive = false
        return constraint
    }
    
    @discardableResult
    func removeAllConstraints() -> OSView{
        for constraint in self.constraints{
            removeConstraint(constraint)
        }
        return self
    }
    
    // subviews
    
    @discardableResult
    func addSubviewFilling(_ subview: OSView, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewFillingSafeArea(_ subview: OSView, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, insets: insets)
        return subview
    }
    
#if os(iOS)
    @discardableResult
    func addSubviewFillingSafeAreaWithKeyboard(_ subview: OSView, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: safeAreaLayoutGuide.topAnchor, leading: safeAreaLayoutGuide.leadingAnchor, trailing: safeAreaLayoutGuide.trailingAnchor, bottom: keyboardLayoutGuide.topAnchor, insets: insets)
        return subview
    }
#endif
    
    @discardableResult
    func addSubviewWithAnchors(_ subview: OSView, top: NSLayoutYAxisAnchor? = nil, leading: NSLayoutXAxisAnchor? = nil, trailing: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: top, leading: leading, trailing: trailing, bottom: bottom, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewCentered(_ subview: OSView, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil) -> OSView{
        addSubview(subview)
        subview.setAnchors(centerX: centerX,centerY: centerY)
        return subview
    }
    
    @discardableResult
    func addSubviewBelow(_ subview: OSView, upperView: OSView? = nil, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: upperView?.bottomAnchor ?? topAnchor, leading: leadingAnchor, trailing: trailingAnchor, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewCenteredBelow(_ subview: OSView, upperView: OSView? = nil, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: upperView?.bottomAnchor ?? topAnchor, insets: insets)
            .centerX(centerXAnchor)
        return subview
    }
    
    @discardableResult
    func addSubviewToRight(_ subview: OSView, leftView: OSView? = nil, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: topAnchor, leading: leftView?.trailingAnchor ?? leadingAnchor, bottom: bottomAnchor, insets: insets)
        return subview
    }
    
    @discardableResult
    func addSubviewToLeft(_ subview: OSView, rightView: OSView? = nil, insets: OSInsets = .defaultInsets) -> OSView{
        addSubview(subview)
        subview.setAnchors(top: topAnchor, trailing: rightView?.leadingAnchor ?? trailingAnchor, bottom: bottomAnchor, insets: insets)
        return subview
    }
    
    @discardableResult
    func connectToBottom(of parentView: OSView, inset: Double = OSInsets.defaultInset) -> OSView{
        self.bottom(parentView.bottomAnchor, inset: -inset)
        return self
    }
    
    @discardableResult
    func connectToRight(of parentView: OSView, inset: Double = OSInsets.defaultInset) -> OSView{
        trailing(parentView.trailingAnchor, inset: -inset)
        return self
    }
    
    @discardableResult
    func connectToLeft(of parentView: OSView, inset: Double = OSInsets.defaultInset) -> OSView{
        leading(parentView.leadingAnchor, inset: inset)
        return self
    }
    
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    func removeSubview(_ view : OSView) {
        for subview in subviews {
            if subview == view{
                subview.removeFromSuperview()
                break
            }
        }
    }

}

#endif
