/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol CheckboxDelegate{
    func checkboxIsSelected(index: Int, value: String)
}

class Checkbox: NSView{
    
    var label = NSTextField(labelWithString: "")
    var checkboxIcon = CheckboxIcon()
    var index: Int = 0
    var data: AnyObject? = nil
    var title: String{
        get{
            label.stringValue
        }
        set{
            label.stringValue = newValue
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
    func withTextColor(_ color: NSColor) -> Checkbox{
        label.textColor = color
        return self
    }
    
    @discardableResult
    func withIconColor(_ color: NSColor) -> Checkbox{
        checkboxIcon.withIconColor(color)
        return self
    }
    
    @discardableResult
    func withColor(_ color: NSColor) -> Checkbox{
        label.textColor = color
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
        super.init(offImage: NSImage(systemSymbolName: "square", accessibilityDescription: nil)!, onImage: NSImage(systemSymbolName: "checkmark.square", accessibilityDescription: nil)!)
        onColor = .labelColor
        offColor = .labelColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    func withIconColor(_ color: NSColor) -> CheckboxIcon{
        onColor = color
        offColor = color
        return self
    }
    
}



