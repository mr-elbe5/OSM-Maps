/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol OnOffIconDelegate{
    func onOffValueDidChange(icon: OnOffIcon)
}

class OnOffIcon : NSButton{
    
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
    
    var onImage : NSImage
    var offImage : NSImage
    
    var onColor : NSColor!
    var offColor : NSColor!
    
    var delegate : OnOffIconDelegate? = nil
    
    init(offImage: NSImage, onImage: NSImage, isOn : Bool  = false){
        self.offImage = offImage
        self.onImage = onImage
        self._isOn = isOn
        super.init(frame: .zero)
        bezelStyle = .smallSquare
        onColor = contentTintColor
        offColor = contentTintColor
        image = isOn ? onImage : offImage
        image!.size = NSSize(width: 16, height: 16)
        target = self
        action = #selector(changeValue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func changeValue(){
        self.isOn = !self.isOn
        self.delegate?.onOffValueDidChange(icon: self)
    }
    
    func setIconAndColor(){
        if isOn{
            image = onImage
            contentTintColor = onColor
        }
        else{
            image = offImage
            contentTintColor = offColor
        }
    }
    
}

