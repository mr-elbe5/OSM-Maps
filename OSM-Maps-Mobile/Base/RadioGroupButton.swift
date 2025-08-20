/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol RadioGroupButtonDelegate{
    func radioIsSelected(index: Int)
}

class RadioGroupButton: UIView{
    
    var label = UILabel()
    var radioButton = RadioButton()
    var index: Int = 0
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
            radioButton.isOn
        }
        set{
            radioButton.isOn = newValue
        }
    }
    
    var delegate: RadioGroupButtonDelegate? = nil
    
    func setup(title: String, index: Int, isOn: Bool = false){
        self.index = index
        self.title = title
        self.isOn = isOn
        radioButton.delegate = self
        addSubviewToRight(radioButton)
        addSubviewToRight(label)
            .connectToRight(of: self)
    }
    
}

extension RadioGroupButton: OnOffIconDelegate{
    
    func onOffValueDidChange(icon: OnOffIcon) {
        delegate?.radioIsSelected(index: index)
    }
    
}

class RadioButton: OnOffIcon{
    
    init(isOn: Bool = false){
        super.init(offImage: UIImage(systemName: "circle")!, onImage: UIImage(systemName: "record.circle")!)
        onColor = .label
        offColor = .label
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addAction(){
        self.addAction(UIAction(){ action in
            if !self.isOn{
                self.isOn = true
                self.delegate?.onOffValueDidChange(icon: self)
            }
        }, for: .touchDown)
    }
    
}

