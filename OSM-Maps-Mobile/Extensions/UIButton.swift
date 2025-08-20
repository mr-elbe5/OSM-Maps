/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

extension UIButton{
    
    convenience init(name: String, action: UIAction){
        self.init(frame: .zero)
        setTitle(name, for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        addAction(action, for: .touchDown)
    }
    
    @discardableResult
    func asIconButton(_ icon: String, color: UIColor = .label) -> UIButton{
        setImage(UIImage(systemName: icon), for: .normal)
        self.tintColor = color
        self.scaleBy(1.25)
        return self
    }
    
    @discardableResult
    func asImageButton(_ image: String) -> UIButton{
        setImage(UIImage(named: image), for: .normal)
        return self
    }
    
    @discardableResult
    func asTextButton(_ text: String) -> UIButton{
        setTitle(text, for: .normal)
        return self
    }
    
    @discardableResult
    func withTextColor(color: UIColor) -> UIButton{
        setTitleColor(color, for: .normal)
        return self
    }
    
    @discardableResult
    func withBackgroundColor(color: UIColor) -> UIButton{
        self.backgroundColor = color
        layer.cornerRadius = 5
        layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func withRoundedCorners() -> UIButton{
        layer.cornerRadius = 5
        layer.masksToBounds = true
        return self
    }
    
}

