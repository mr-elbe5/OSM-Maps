/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

class NoteListViewController: ItemListViewController{
    
    var notes: NoteItemList{
        items as! NoteItemList
    }
    
    init(){
        super.init(title: "notes".localize())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadItems(){
        if ViewFilter.shared.isActive{
            items = ViewFilter.shared.filteredNotes(notes: AppData.shared.notes)
        }
        else{
            items = AppData.shared.notes
        }
        setupData()
        self.tableView.reloadData()
    }
    
}
    
    
