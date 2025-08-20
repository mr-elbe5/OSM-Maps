/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol OnOffIconDelegate{
    func onOffValueDidChange(icon: OnOffIcon)
}

class OnOffIcon : UIButton{
    
    private var _isOn : Bool
    
    var isOn: Bool{
        get{
            _isOn
        }
        set{
            _isOn = newValue
            setIconAndColor()
        }
    }
    
    var onImage : UIImage
    var offImage : UIImage
    
    var onColor : UIColor!
    var offColor : UIColor!
    
    var delegate : OnOffIconDelegate? = nil
    
    init(offImage: UIImage, onImage: UIImage, isOn : Bool  = false){
        self.offImage = offImage
        self.onImage = onImage
        self._isOn = isOn
        super.init(frame: .zero)
        onColor = tintColor
        offColor = tintColor
        setImage(isOn ? onImage : offImage, for: .normal)
        self.scaleBy(1.25)
        addAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addAction(){
        self.addAction(UIAction(){ action in
            self.isOn = !self.isOn
            self.delegate?.onOffValueDidChange(icon: self)
        }, for: .touchDown)
    }
    
    func setIconAndColor(){
        if isOn{
            setImage(onImage, for: .normal)
            tintColor = onColor
            setTitleColor(onColor, for: .normal)
        }
        else{
            setImage(offImage, for: .normal)
            tintColor = offColor
            setTitleColor(offColor, for: .normal)
        }
    }
    
}

