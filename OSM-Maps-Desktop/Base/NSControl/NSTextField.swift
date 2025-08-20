/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSTextField{
    
    @discardableResult
    func asHeadline() -> NSTextField{
        isBezeled = false
        drawsBackground = false
        isEditable = false
        isSelectable = false
        font = NSFont.preferredFont(forTextStyle: .headline)
        maximumNumberOfLines = 0
        return self
    }
    
    @discardableResult
    func asLabel() -> NSTextField{
        isBezeled = false
        drawsBackground = false
        isEditable = false
        isSelectable = false
        maximumNumberOfLines = 0
        lineBreakStrategy = .standard
        return self
    }
    
    @discardableResult
    func asSmallLabel() -> NSTextField{
        isBezeled = false
        drawsBackground = false
        isEditable = false
        isSelectable = false
        lineBreakStrategy = .standard
        maximumNumberOfLines = 0
        font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        return self
    }
    
    @discardableResult
    func asEditableField(text: String) -> NSTextField{
        stringValue = text
        isBezeled = true
        drawsBackground = true
        isEditable = true
        isSelectable = true
        isAutomaticTextCompletionEnabled = false
        maximumNumberOfLines = 0
        return self
    }
    
    @discardableResult
    func asSmallCompressable() -> NSTextField{
        font = .systemFont(ofSize: NSFont.smallSystemFontSize)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return self
    }

}

extension NSTextField{
    
    private static let commandKey = NSEvent.ModifierFlags.command.rawValue
    private static let commandShiftKey = NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue
    
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.type == NSEvent.EventType.keyDown {
            if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSTextField.commandKey {
                switch event.charactersIgnoringModifiers! {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return true }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return true }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return true }
                case "z":
                    if NSApp.sendAction(Selector(("undo:")), to: nil, from: self) { return true }
                case "a":
                    if NSApp.sendAction(#selector(NSResponder.selectAll(_:)), to: nil, from: self) { return true }
                default:
                    break
                }
            } else if (event.modifierFlags.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue) == NSTextField.commandShiftKey {
                if event.charactersIgnoringModifiers == "Z" {
                    if NSApp.sendAction(Selector(("redo:")), to: nil, from: self) { return true }
                }
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}


