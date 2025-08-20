/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit



protocol NoteCellDelegate{
    func editNote(_ note: NoteItem)
}

class NoteCellView : MapItemCellView{
    
    var note: NoteItem
    
    var selectedButton: NSButton!
    
    var delegate: NoteCellDelegate? = nil
    
    init(note: NoteItem){
        self.note = note
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "note".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor, leading: leadingAnchor, insets: OSInsets.defaultInsets)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor, insets: OSInsets.smallInsets)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editNote))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: note.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        let nameField = NSTextField(wrappingLabelWithString: note.name)
        addSubviewBelow(nameField, upperView: iconBar)
        let noteField = NSTextField(wrappingLabelWithString: note.note)
        addSubviewBelow(noteField, upperView: nameField)
            .connectToBottom(of: self)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: note.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func editNote(){
        delegate?.editNote(note)
    }
    
    @objc func selectionChanged(){
        note.selected = !note.selected
        updateIconView()
    }
    
}
