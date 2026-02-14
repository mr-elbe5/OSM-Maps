/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class SaveRouteViewController: ModalViewController {
    
    var nameField = NSTextField()
    
    var item: RouteItem
    
    init(item: RouteItem){
        self.item = item
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        let header = NSTextField(labelWithString: "route".localize()).asHeadline()
        view.addSubviewBelow(header)
        nameField.asEditableField(text: item.route.name)
        view.addSubviewBelow(nameField, upperView: header)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewCenteredBelow(saveButton, upperView: nameField)
            .connectToBottom(of: view)
    }
    
    @objc func save(){
        item.route.name = nameField.stringValue
        responseCode = .OK
        self.view.window?.close()
    }
    
}
