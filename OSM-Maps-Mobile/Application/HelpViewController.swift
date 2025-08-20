/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class HelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "help".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var header = HelpText(headerKey: "helpGeneral")
        contentView.addSubviewBelow(header)
        var text = HelpText(key: "helpGeneralText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(headerKey: "helpMap")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpMapText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(headerKey: "helpNotes")
        contentView.addSubviewBelow(header, upperView: text)
        var iconText = HelpText(icon: "note.text", key: "notesList")
        contentView.addSubviewBelow(iconText, upperView: header)
        text = HelpText(key: "helpNotesText")
        contentView.addSubviewBelow(text, upperView: iconText)
        
        header = HelpText(headerKey: "helpImages")
        contentView.addSubviewBelow(header, upperView: text)
        iconText = HelpText(icon: "photo", key: "imagesList")
        contentView.addSubviewBelow(iconText, upperView: header)
        text = HelpText(key: "helpImagesText")
        contentView.addSubviewBelow(text, upperView: iconText)
        
        header = HelpText(headerKey: "helpTracks")
        contentView.addSubviewBelow(header, upperView: text)
        iconText = HelpText(icon: "figure.walk", key: "tracksList")
        contentView.addSubviewBelow(iconText, upperView: header)
        text = HelpText(key: "helpTracksText")
        contentView.addSubviewBelow(text, upperView: iconText)
        
        header = HelpText(icon: "calendar", headerKey: "helpViewFilter")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpViewFilterText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(icon: "icloud", headerKey: "helpICloud")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpICloudText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(icon: "square.and.arrow.down", headerKey: "helpBackup")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpBackupText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(icon: "gearshape", headerKey: "helpPreferences")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpPreferencesText")
        contentView.addSubviewBelow(text, upperView: header)
        
            .connectToBottom(of: contentView)
        
    }
    
}
