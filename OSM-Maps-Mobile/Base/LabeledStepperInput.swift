/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

import UIKit

class LabeledStepperInput : UIView{
    
    private var label = UILabel()
    private var stepper = UIStepper()
    
    var value: Int{
        get{
            return Int(stepper.value)
        }
        set{
            stepper.value = Double(newValue)
        }
    }
    
    func setupView(labelText: String, value: Int = 0){
        label.text = labelText
        label.textAlignment = .left
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        addSubview(label)
        
        stepper.backgroundColor = .tertiarySystemBackground
        stepper.setRoundedBorders()
        self.value = value
        addSubview(stepper)
        
        label.setAnchors(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        stepper.setAnchors(top: label.bottomAnchor, leading: leadingAnchor, bottom: bottomAnchor, insets: .zero)
    }
    
    func setMinMaxValue(minValue: Int, maxValue: Int){
        stepper.minimumValue = Double(minValue)
        stepper.maximumValue = Double(maxValue)
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledStepperInput{
        label.textColor = color
        return self
    }
    
}
