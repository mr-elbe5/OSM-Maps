/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol SwitchDelegate{
    func switchValueDidChange(sender: LabeledSwitchView,isOn: Bool)
}

class LabeledSwitchView : UIView{
    
    private var label = UILabel()
    private var switcher = UISwitch()
    
    var delegate : SwitchDelegate? = nil
    
    var isOn : Bool{
        get{
            switcher.isOn
        }
        set{
            switcher.isOn = newValue
        }
    }
    
    func setupView(labelText: String, isOn : Bool){
        label.text = labelText
        label.textAlignment = .left
        addSubviewToRight(label)
        
        switcher.scaleBy(0.75)
        switcher.isOn = isOn
        switcher.addAction(UIAction(){ action in
            self.delegate?.switchValueDidChange(sender: self,isOn: self.switcher.isOn)
        }, for: .valueChanged)
        addSubviewToLeft(switcher)
    }
    
    func setEnabled(_ flag: Bool){
        switcher.isEnabled = flag
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> LabeledSwitchView{
        label.textColor = color
        return self
    }
    
}

