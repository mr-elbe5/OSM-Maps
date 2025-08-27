/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class NoteHelpViewController: ScrollViewController{
    
    override func loadView() {
        title = "helpNotes".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var iconText = HelpText(icon: "note.text", key: "notesList")
        contentView.addSubviewBelow(iconText)
        var text = HelpText(key: "helpNotesText")
        contentView.addSubviewBelow(text, upperView: iconText)
            .connectToBottom(of: contentView)
        
    }
    
}
