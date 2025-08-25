/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import AVKit

protocol AudioCellDelegate{
    func editAudio(_ audio: AudioItem)
}

class AudioCellView : MapItemCellView{
    
    var audio: AudioItem
    
    var selectedButton: NSButton!
    
    var delegate: AudioCellDelegate? = nil
    
    init(audio:AudioItem){
        self.audio = audio
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView() {
        super.setupView()
        let titleField = NSTextField(wrappingLabelWithString: "audio".localize()).asHeadline()
        addSubviewWithAnchors(titleField, top: topAnchor,leading: leadingAnchor, insets: OSInsets.defaultInsets)
        let iconBar = IconBar()
        addSubviewWithAnchors(iconBar, top: topAnchor, trailing: trailingAnchor)
        let editButton = NSButton(icon: "pencil", target: self, action: #selector(editAudio))
        iconBar.addArrangedSubview(editButton)
        selectedButton = NSButton(icon: audio.selected ? "checkmark.square" : "square", target: self, action: #selector(selectionChanged))
        iconBar.addArrangedSubview(selectedButton)
        let audioView = AudioPlayerView()
        audioView.setupView()
        audioView.url = audio.url
        audioView.enablePlayer()
        addSubviewWithAnchors(audioView, top: iconBar.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor)
        audioView.bottom(bottomAnchor)
    }
    
    override func updateIconView() {
        selectedButton.image = NSImage(systemSymbolName: audio.selected ? "checkmark.square" : "square", accessibilityDescription: .none)
    }
    
    @objc func editAudio(){
        delegate?.editAudio(audio)
    }
    
    @objc func selectionChanged(){
        audio.selected = !audio.selected
        updateIconView()
    }
    
}
