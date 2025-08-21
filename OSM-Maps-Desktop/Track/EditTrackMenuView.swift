/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol EditTrackMenuDelegate{
    func toggleSelectAllTrackpoints()
    func selectLeading()
    func selectTrailing()
    func deleteSelectedTrackpoints()
    func insertTrackpointAfter()
    func insertTrackpointBefore()
    func undoTrackChanges()
}

class EditTrackMenuView: NSView{
    
    var selectAllButton: NSButton!
    var deleteSelectedButton: NSButton!
    var selectLeadingButton: NSButton!
    var selectTrailingButton: NSButton!
    var insertBeforeButton: NSButton!
    var insertAfterButton: NSButton!
    var undoButton: NSButton!
    
    var delegate: EditTrackMenuDelegate? = nil
    
    override func setupView(){
        backgroundColor = .black
        selectAllButton = NSButton(icon: "checkmark.square", color: .white, target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        addSubviewWithAnchors(selectAllButton, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        selectLeadingButton = NSButton(icon: "arrow.left", target: self, action: #selector(selectLeading))
        selectLeadingButton.toolTip = "selectLeading".localize()
        addSubviewWithAnchors(selectLeadingButton, top: topAnchor, leading: selectAllButton.trailingAnchor, bottom: bottomAnchor)
        selectTrailingButton = NSButton(icon: "arrow.right", target: self, action: #selector(selectTrailing))
        selectTrailingButton.toolTip = "selectTrailing".localize()
        addSubviewWithAnchors(selectTrailingButton, top: topAnchor, leading: selectLeadingButton.trailingAnchor, bottom: bottomAnchor)
        insertBeforeButton = NSButton(icon: "arrow.backward.circle", target: self, action: #selector(insertTrackpointBefore))
        insertBeforeButton.toolTip = "insertTrackpointBefore".localize()
        addSubviewWithAnchors(insertBeforeButton, top: topAnchor, leading: selectTrailingButton.trailingAnchor, bottom: bottomAnchor)
        insertAfterButton = NSButton(icon: "arrow.forward.circle", target: self, action: #selector(insertTrackpointAfter))
        insertAfterButton.toolTip = "insertTrackpointAfter".localize()
        addSubviewWithAnchors(insertAfterButton, top: topAnchor, leading: insertBeforeButton.trailingAnchor, bottom: bottomAnchor)
        deleteSelectedButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteSelectedButton.toolTip = "deleteSelected".localize()
        addSubviewWithAnchors(deleteSelectedButton, top: topAnchor, leading: insertAfterButton.trailingAnchor, bottom: bottomAnchor)
        undoButton = NSButton(icon: "arrow.uturn.backward", color: .white, target: self, action: #selector(undo))
        undoButton.toolTip = "reset".localize()
        addSubviewWithAnchors(undoButton, top: topAnchor, leading: deleteSelectedButton.trailingAnchor, bottom: bottomAnchor)
    }
    
    @objc func toggleSelectAll(){
        delegate?.toggleSelectAllTrackpoints()
    }
    
    @objc func selectLeading(){
        delegate?.selectLeading()
    }
    
    @objc func selectTrailing(){
        delegate?.selectTrailing()
    }
    
    @objc func deleteSelected(){
        delegate?.deleteSelectedTrackpoints()
    }
    
    @objc func insertTrackpointBefore(){
        delegate?.insertTrackpointBefore()
    }
    
    @objc func insertTrackpointAfter(){
        delegate?.insertTrackpointAfter()
    }
    
    @objc func undo(){
        delegate?.undoTrackChanges()
    }
    
}
    
