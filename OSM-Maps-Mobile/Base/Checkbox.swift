/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol CheckboxDelegate{
    func checkboxIsSelected(index: Int, value: String)
}

class Checkbox: UIView{
    
    var label = UILabel()
    var checkboxIcon = CheckboxIcon()
    var index: Int = 0
    var data: AnyObject? = nil
    var title: String{
        get{
            label.text ?? ""
        }
        set{
            label.text = newValue
        }
    }
    var isOn: Bool{
        get{
            checkboxIcon.isOn
        }
        set{
            checkboxIcon.isOn = newValue
        }
    }
    
    var delegate: CheckboxDelegate? = nil
    
    func setup(title: String, index: Int = 0, data: AnyObject? = nil, isOn: Bool = false){
        self.index = index
        self.title = title
        self.data = data
        self.isOn = isOn
        checkboxIcon.delegate = self
        addSubviewToRight(checkboxIcon)
        addSubviewToRight(label,leftView: checkboxIcon)
            .connectToRight(of: self, inset: OSInsets.defaultInset)
    }
    
    @discardableResult
    func withTextColor(_ color: UIColor) -> Checkbox{
        label.textColor = color
        return self
    }
    
    @discardableResult
    func withIconColor(_ color: UIColor) -> Checkbox{
        checkboxIcon.withIconColor(color)
        return self
    }
    
}

extension Checkbox: OnOffIconDelegate{
    
    func onOffValueDidChange(icon: OnOffIcon) {
        delegate?.checkboxIsSelected(index: index, value: title)
    }
    
}

class CheckboxIcon: OnOffIcon{
    
    init(isOn: Bool = false){
        super.init(offImage: UIImage(systemName: "square")!, onImage: UIImage(systemName: "checkmark.square")!)
        onColor = .label
        offColor = .label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func withIconColor(_ color: UIColor) -> CheckboxIcon{
        onColor = color
        offColor = color
        return self
    }
    
}



