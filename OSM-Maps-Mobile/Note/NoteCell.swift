/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol NoteCellDelegate: MapItemCellDelegate, EditNoteDelegate {
}

class NoteCell: MapItemCell{
    
    static let CELL_IDENT = "noteCell"
    
    var item : NoteItem? = nil {
        didSet {
            setupCell()
        }
    }
    
    var delegate: NoteCellDelegate?
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let note = item{
            let selectedButton = UIButton().asDarkIconButton(note.selected ? "checkmark.square" : "square")
            selectedButton.addAction(UIAction(){ action in
                note.selected = !note.selected
                selectedButton.setImage(UIImage(systemName: note.selected ? "checkmark.square" : "square"), for: .normal)
                self.delegate?.selectionChanged()
            }, for: .touchDown)
            iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
            let editButton = UIButton().asDarkIconButton("pencil")
            editButton.addAction(UIAction(){ action in
                let controller = EditNoteViewController(item: note)
                controller.delegate = self
                MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(editButton, rightView: selectedButton, insets: iconInsets)
            let mapButton = UIButton().asDarkIconButton("map")
            mapButton.addAction(UIAction(){ action in
                MainViewController.shared.showItemOnMap(item: note)
                MainViewController.shared.navigationController?.popToRootViewController(animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(mapButton, rightView: editButton, insets: iconInsets)
                .connectToLeft(of: iconView)
        }
    }
    
    override func setupTimeLabel(){
        timeLabel.text = item?.creationDate.dateTimeString
    }
    
    override func setupMapIcon() {
        if let item = item{
            mapIconView.image = UIImage(systemName: item.hasValidCoordinate ? "mappin" : "mappin.slash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24))?
                .withTintColor(.systemGreen).withRenderingMode(.alwaysOriginal)
            
        }
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let note = item{
            let header = UILabel(header: "note".localize())
            itemView.addSubviewCenteredBelow(header)
            let noteLabel = UILabel(text: note.note)
            itemView.addSubviewBelow(noteLabel, upperView: header)
                .connectToBottom(of: itemView)
        }
    }
    
}

extension NoteCell : EditNoteDelegate{
    
    func noteChanged(item: NoteItem) {
      delegate?.noteChanged(item: item)
    }
    
}

extension NoteCell: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        if let note = item{
            note.note = textView.text
        }
    }
    
}


