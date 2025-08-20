/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

class CheckboxGroupView: UIView{
    
    var selectedIndex : Int = -1
    var selectedValue : String{
        if selectedIndex != -1{
            return checkboxViews[selectedIndex].title
        }
        return ""
    }
    
    var onOffCheckbox = CheckboxGroupIcon()
    var checkboxViews = Array<Checkbox>()
    var stackView = UIStackView()
    
    var hasSelection: Bool{
        for checkboxView in checkboxViews{
            if checkboxView.isOn{
                return true
            }
        }
        return false
    }
    
    init(){
        super.init(frame: .zero)
        backgroundColor = .tertiarySystemBackground
        setRoundedBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        stackView.axis = .vertical
        stackView.alignment = .leading
        addSubviewFilling(stackView, insets: .zero)
        onOffCheckbox.setup(isOn: true)
        onOffCheckbox.checkboxIcon.delegate = self
        stackView.addArrangedSubview(onOffCheckbox)
    }
    
    func addCheckbox(cb: Checkbox){
        checkboxViews.append(cb)
        stackView.addArrangedSubview(cb)
    }
    
    func select(index: Int){
        selectedIndex = index
        for checkboxView in checkboxViews{
            checkboxView.isOn = checkboxView.index == index
        }
    }
    
}

extension CheckboxGroupView: OnOffIconDelegate{
    
    func onOffValueDidChange(icon: OnOffIcon) {
        if icon == onOffCheckbox.checkboxIcon{
            for cb in checkboxViews{
                cb.isOn = icon.isOn
            }
        }
    }
    
}

class CheckboxGroupIcon: UIView{
    
    var checkboxIcon = CheckboxIcon()
    var isOn: Bool{
        get{
            checkboxIcon.isOn
        }
        set{
            checkboxIcon.isOn = newValue
        }
    }
    
    func setup(isOn: Bool = false){
        self.isOn = isOn
        addSubviewFilling(checkboxIcon)
    }
    
}
