/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSButton{
    
    convenience init(icon: String, target: NSView, action: Selector){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!, target: target, action: action)
    }
    
    convenience init(icon: String, color: NSColor, target: NSView, action: Selector){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!.withTintColor(color), target: target, action: action)
    }
    
    convenience init(icon: String, color: NSColor, backgroundColor: NSColor, target: NSView, action: Selector){
        self.init(image: NSImage(systemSymbolName: icon, accessibilityDescription: nil)!.withTintColor(color), target: target, action: action)
        self.backgroundColor = backgroundColor
    }
    
    @discardableResult
    func withStyle(_ style: BezelStyle) -> NSButton{
        self.bezelStyle = style
        return self
    }
    
    @discardableResult
    func asIconButton(_ icon: String, color: NSColor = .darkGray) -> NSButton{
        image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)?.withTintColor(color)
        return self
    }
    
    @discardableResult
    func asImageButton(_ image: String) -> NSButton{
        self.image = NSImage(named: image)
        return self
    }

    @discardableResult
    func asTextButton(_ text: String, color: NSColor = .controlTextColor, backgroundColor: NSColor? = nil) -> NSButton{
        title = text
        self.contentTintColor = color
        if let bgcol = backgroundColor{
            self.wantsLayer = true
            layer?.backgroundColor = bgcol.cgColor
            layer?.cornerRadius = 5
            layer?.masksToBounds = true
        }
        return self
    }
    
    func setAction(target: NSView, action: Selector){
        self.target = target
        self.action = action
    }
    
    @discardableResult
    func asTextButton(_ text: String, target: NSView, action: Selector) -> NSButton{
        title = text
        self.target = target
        self.action = action
        return self
    }
    
    @discardableResult
    func asLightIconButton(_ icon: String) -> NSButton{
        return asIconButton(icon, color: .lightColor)
    }
    
    @discardableResult
    func asDarkIconButton(_ icon: String) -> NSButton{
        return asIconButton(icon, color: .darkColor)
    }
    
    @discardableResult
    func asWarnIconButton(_ icon: String) -> NSButton{
        return asIconButton(icon, color: .warnColor)
    }
    
    @discardableResult
    func asLightTextButton(_ text: String) -> NSButton{
        return asTextButton(text, color: .lightColor)
    }
    
    @discardableResult
    func asDarkTextButton(_ text: String) -> NSButton{
        return asTextButton(text, color: .lightColor)
    }
    
    @discardableResult
    func asBlueTextButton(_ text: String) -> NSButton{
        return asTextButton(text, color: .blueColor)
    }
    
    @discardableResult
    func asWarnTextButton(_ text: String) -> NSButton{
        return asTextButton(text, color: .warnColor)
    }
    
}

