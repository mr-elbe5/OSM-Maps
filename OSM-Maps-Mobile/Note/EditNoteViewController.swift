/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol EditNoteDelegate {
    func noteChanged(item: NoteItem)
}

class EditNoteViewController: ScrollViewController{
    
    var item : NoteItem
    var noteEditView = TextEditArea().defaultWithBorder()
    
    var delegate: EditNoteDelegate?
    
    init(item: NoteItem){
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "note".localize()
        setupScrollView()
        addScrollViewFillingWithKeyboard()
        loadScrollableSubviews()
        noteEditView.becomeFirstResponder()
    }
    
    func loadScrollableSubviews() {
        noteEditView.text = item.note
        contentView.addSubviewBelow(noteEditView)
        let saveButton = TextButton(text: "save".localize())
            saveButton.addAction(UIAction(){ action in
                self.save()
            }, for: .touchDown)
        contentView.addSubviewCenteredBelow(saveButton, upperView: noteEditView)
            .connectToBottom(of: contentView)
    }
    
    func save(){
        self.close()
        item.note = noteEditView.text
        item.setModified()
        if !AppData.shared.notes.contains(where: {
            $0.id == item.id
        }){
            MainViewController.shared.addNote(item: item)
        }
        AppData.shared.save()
        delegate?.noteChanged(item: item)
    }
    
}



