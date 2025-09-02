/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import CoreLocation

class AudioCell: MapItemCell{
    
    var item : AudioItem
    
    var selectedButton: NSButton!
    
    init(audio: AudioItem){
        self.item = audio
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupIconView(){
        iconView.removeAllSubviews()
        selectedButton = NSButton(icon: item.selected ? "checkmark.square" : "square", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(toggleSelection))
        iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
        let editButton = NSButton(icon: "pencil", color: .lightColor, backgroundColor: .darkColor, target: self, action: #selector(editAudio))
        iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
            .connectToLeft(of: iconView)
    }
    
    override func setupTimeLabel(){
        timeLabel.stringValue = item.creationDate.dateTimeString()
    }
    
    override func setupMapIcon() {
        mapIconView.image = NSImage(systemSymbolName: item.hasValidCoordinate ? "mappin" : "mappin.slash", accessibilityDescription: nil)!.withTintColor(.red)
    }
    
    override func setupItemView(){
        itemView.removeAllSubviews()
        let audioView = AudioPlayerView()
        audioView.setupView()
        audioView.url = item.url
        audioView.enablePlayer()
        itemView.addSubviewBelow(audioView)
            .connectToBottom(of: itemView)
    }
    
    @objc func toggleSelection(){
        item.selected = !item.selected
        selectedButton.image = NSImage(systemSymbolName: item.selected ? "checkmark.square" : "square", accessibilityDescription: nil)
    }
    
    @objc func editAudio(){
        MainViewController.shared.editAudio(item)
    }
    
}



