/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol EditTrackMenuDelegate{
    func toggleSelectAllTrackpoints()
    func deleteSelectedTrackpoints()
    func undoTrackChanges()
}

class EditTrackMenuView: NSView{
    
    var selectAllButton: NSButton!
    var deleteSelectedButton: NSButton!
    var undoButton: NSButton!
    
    var delegate: EditTrackMenuDelegate? = nil
    
    override func setupView(){
        backgroundColor = .black
        selectAllButton = NSButton(icon: "checkmark.square", color: .white, target: self, action: #selector(toggleSelectAll))
        selectAllButton.toolTip = "selectAll".localize()
        addSubviewWithAnchors(selectAllButton, top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor)
        deleteSelectedButton = NSButton(icon: "trash.square", color: .systemRed, target: self, action: #selector(deleteSelected))
        deleteSelectedButton.toolTip = "deleteSelected".localize()
        addSubviewWithAnchors(deleteSelectedButton, top: topAnchor, leading: selectAllButton.trailingAnchor, bottom: bottomAnchor)
        undoButton = NSButton(icon: "arrow.uturn.backward", color: .white, target: self, action: #selector(undo))
        undoButton.toolTip = "undo".localize()
        addSubviewWithAnchors(undoButton, top: topAnchor, leading: deleteSelectedButton.trailingAnchor, bottom: bottomAnchor)
    }
    
    @objc func toggleSelectAll(){
        delegate?.toggleSelectAllTrackpoints()
    }
    
    @objc func deleteSelected(){
        delegate?.deleteSelectedTrackpoints()
    }
    
    @objc func undo(){
        delegate?.undoTrackChanges()
    }
    
}
    
