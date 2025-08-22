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
    func asIconButton(_ icon: String, color: UIColor? = nil) -> UIButton{
        setImage(UIImage(systemName: icon), for: .normal)
        if let color = color{
            self.tintColor = color
        }
        self.scaleBy(1.25)
        return self
    }
    
    @discardableResult
    func asLightIconButton(_ icon: String) -> UIButton{
        return asIconButton(icon, color: .lightColor)
    }
    
    @discardableResult
    func asDarkIconButton(_ icon: String) -> UIButton{
        return asIconButton(icon, color: .darkColor)
    }
    
    @discardableResult
    func asWarnIconButton(_ icon: String) -> UIButton{
        return asIconButton(icon, color: .warnColor)
    }
    
    @discardableResult
    func asImageButton(_ image: String) -> UIButton{
        setImage(UIImage(named: image), for: .normal)
        return self
    }
    
    @discardableResult
    func asTextButton(_ text: String, color: UIColor? = nil) -> UIButton{
        setTitle(text, for: .normal)
        if let color = color{
            setTitleColor(color, for: .normal)
        }
        return self
    }
    
    @discardableResult
    func asLightTextButton(_ text: String) -> UIButton{
        return asTextButton(text, color: .lightColor)
    }
    
    @discardableResult
    func asDarkTextButton(_ text: String) -> UIButton{
        return asTextButton(text, color: .lightColor)
    }
    
    @discardableResult
    func asBlueTextButton(_ text: String) -> UIButton{
        return asTextButton(text, color: .blueColor)
    }
    
    @discardableResult
    func asWarnTextButton(_ text: String) -> UIButton{
        return asTextButton(text, color: .warnColor)
    }
    
    @discardableResult
    func withRoundedCorners(backgroundColor: UIColor? = nil) -> UIButton{
        if let backgroundColor = backgroundColor{
            self.backgroundColor = backgroundColor
        }
        layer.cornerRadius = 5
        layer.masksToBounds = true
        return self
    }
    
}

