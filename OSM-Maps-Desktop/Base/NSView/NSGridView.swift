/*
 E5MacOSUI
 Base classes and extension for IOS and MacOS
 Copyright: Michael Rönnau mr@elbe5.de
 */


import AppKit

extension NSGridView{
    
    @discardableResult
    func addLabeledRow(label: String, views: [NSView]) -> NSGridRow{
        var arr = [NSView]()
        arr.append(NSTextField(labelWithString: label))
        arr.append(contentsOf: views)
        return addRow(with: arr)
    }
    
    @discardableResult
    func addLabeledRow(label: String, view: NSView) -> NSGridRow{
        var arr = [NSView]()
        let labelView = NSTextField(labelWithString: label)
        arr.append(labelView)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        arr.append(view)
        return addRow(with: arr)
    }
    
    @discardableResult
    func addSmallLabeledRow(label: String, view: NSView) -> NSGridRow{
        var arr = [NSView]()
        let labelView = NSTextField(labelWithString: label).asSmallCompressable()
        arr.append(labelView)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        arr.append(view)
        return addRow(with: arr)
    }
    
}

