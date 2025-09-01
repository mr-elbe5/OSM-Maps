/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

protocol EditNoteDelegate {
    func noteChanged(item: NoteItem)
}

class EditNoteViewController: ModalViewController {
    
    var noteNameField = NSTextField()
    var noteTextField = NSTextField()
    
    var item: NoteItem
    
    init(item: NoteItem){
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        let header = NSTextField(labelWithString: "note".localize()).asHeadline()
        view.addSubviewBelow(header)
        noteNameField.asEditableField(text: item.name)
        view.addSubviewBelow(noteNameField, upperView: header)
        noteTextField.asEditableField(text: item.note)
        view.addSubviewBelow(noteTextField, upperView: noteNameField)
            .height(100)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewCenteredBelow(saveButton, upperView: noteTextField)
            .connectToBottom(of: view)
    }
    
    @objc func save(){
        item.note = noteTextField.stringValue
        responseCode = .OK
        self.view.window?.close()
    }
    
}
