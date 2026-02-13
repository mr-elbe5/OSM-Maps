/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class DataHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "helpData".localize(table: "Help")
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var header = HelpText(icon: "icloud", headerKey: "helpICloud")
        contentView.addSubviewBelow(header)
        var text = HelpText(key: "helpICloudText")
        contentView.addSubviewBelow(text, upperView: header)
        
        header = HelpText(icon: "square.and.arrow.down", headerKey: "helpBackup")
        contentView.addSubviewBelow(header, upperView: text)
        text = HelpText(key: "helpBackupText")
        contentView.addSubviewBelow(text, upperView: header)
        
    }
    
}
