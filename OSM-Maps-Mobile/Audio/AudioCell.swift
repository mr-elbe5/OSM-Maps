/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol AudioCellDelegate {
    func audioChanged(_ item: AudioItem)
}

class AudioCell: MapItemCell{
    
    static let CELL_IDENT = "audioCell"
    
    var item : AudioItem? = nil {
        didSet {
            updateCell()
            setSelected(item?.selected ?? false, animated: false)
        }
    }
    
    var delegate: AudioCellDelegate?
    
    override func setupCellBody(){
        cellBody.setRoundedBorders()
        iconView.setBackground(.iconViewBackgroundColor).setGrayRoundedBorders()
        dateTimeView.setBackground(.iconViewBackgroundColor).setGrayRoundedBorders()
        cellBody.addSubviewWithAnchors(dateTimeView, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, insets: OSInsets.smallInsets)
        dateTimeView.addSubviewFilling(timeLabel, insets: OSInsets.smallInsets)
        cellBody.addSubviewWithAnchors(iconView, top: cellBody.topAnchor, trailing: cellBody.trailingAnchor, insets: OSInsets.smallInsets)
        cellBody.addSubviewWithAnchors(itemView, top: iconView.bottomAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor, insets: .zero)
    }
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let audio = item{
            let selectedButton = UIButton().asIconButton(audio.selected ? "checkmark.square" : "square", color: .label)
            selectedButton.addAction(UIAction(){ action in
                audio.selected = !audio.selected
                selectedButton.setImage(UIImage(systemName: audio.selected ? "checkmark.square" : "square"), for: .normal)
            }, for: .touchDown)
            iconView.addSubviewWithAnchors(selectedButton, top: iconView.topAnchor, leading: iconView.leadingAnchor, trailing: iconView.trailingAnchor , bottom: iconView.bottomAnchor, insets: iconInsets)
            
        }
    }
    
    override func updateTimeLabel(){
        timeLabel.text = item?.creationDate.dateTimeString()
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let audio = item{
            let audioView = AudioPlayerView()
            audioView.setupView()
            itemView.addSubviewWithAnchors(audioView, top: itemView.topAnchor, leading: itemView.leadingAnchor, trailing: itemView.trailingAnchor, bottom: itemView.bottomAnchor, insets: UIEdgeInsets(top: 1, left: OSInsets.defaultInset, bottom: OSInsets.defaultInset, right: OSInsets.defaultInset))
            audioView.url = audio.url
            audioView.enablePlayer()
        }
    }

}



