/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

class NoteCell: MapItemCell{
    
    var item : NoteItem
    
    var selectedButton: NSButton!
    
    init(note: NoteItem){
        self.item = note
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(toggleSelection))
        iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
        let editButton = NSButton(icon: "pencil", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(editNote))
        iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
            .connectToLeft(of: iconView)
    }
    
    override func setupTimeLabel(){
        timeLabel.stringValue = item.creationDate.dateTimeString
    }
    
    override func setupMapIcon() {
        mapIconView.image = NSImage(systemSymbolName: item.hasValidCoordinate ? "mappin" : "mappin.slash", accessibilityDescription: nil)?.withTintColor(.green)
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        let nameField = NSTextField(wrappingLabelWithString: item.name).asHeadline()
        itemView.addSubviewBelow(nameField)
        let noteField = NSTextField(wrappingLabelWithString: item.note)
        itemView.addSubviewBelow(noteField, upperView: nameField)
            .connectToBottom(of: itemView)
    }
    
    @objc func toggleSelection(){
        item.selected = !item.selected
        selectedButton.image = NSImage(systemSymbolName: item.selected ? "checkmark.square" : "square", accessibilityDescription: nil)!.withTintColor(.green)
    }
    
    @objc func showOnMap(){
        MainViewController.shared.showItemOnMap(item)
    }
    
    @objc func editNote(){
        MainViewController.shared.editNote(item){
            self.updateItemView()
        }
    }
    
}



