/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import UIKit

class CaptureButton: UIButton {
    
    enum ButtonState: Int {
        case normal, recording
    }
    
    var buttonColor: UIColor = UIColor.red {
        didSet {
            innerCircleLayer.fillColor = buttonColor.cgColor
        }
    }
    
    var outerColor: UIColor = UIColor.white {
        didSet {
            innerCircleLayer.fillColor = buttonColor.cgColor
        }
    }
    
    var buttonState: ButtonState = .normal {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private var innerPath : UIBezierPath{
        get{
            switch buttonState {
                case .normal:    return innerCircle
                case .recording: return innerRect
            }
        }
    }
    
    private var lineWidth: CGFloat {
        return bounds.width * 0.1
    }
    
    lazy private var innerCircleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path      = self.innerPath.cgPath
        layer.fillColor = self.buttonColor.cgColor
        return layer
    }()
    
    lazy private var outerCircleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path        = self.outerCircle.cgPath
        layer.fillColor   = UIColor.clear.cgColor
        layer.strokeColor = self.outerColor.cgColor
        layer.lineWidth   = lineWidth
        return layer
    }()
    
    private var innerCircle: UIBezierPath {
        let side = self.bounds.width - self.lineWidth*2 - self.lineWidth*2/3
        return UIBezierPath(
            roundedRect: CGRect(x: bounds.width/2 - side/2, y: bounds.width/2 - side/2, width: side, height: side),
            cornerRadius: side/2
        )
    }
    
    private var outerCircle: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: self.bounds.width/2 - self.lineWidth/2,
            startAngle: -.pi/2,
            endAngle: .pi*2 - .pi/2,
            clockwise: true
        )
    }
    
    private var innerRect: UIBezierPath {
        let side = bounds.width * 0.4
        return UIBezierPath(
            roundedRect: CGRect(x: bounds.width/2 - side/2, y: bounds.width/2 - side/2, width: side, height: side),
            cornerRadius: side * 0.1
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.addSublayer(outerCircleLayer)
        layer.addSublayer(innerCircleLayer)
        innerCircleLayer.path = innerPath.cgPath
    }
    
}
