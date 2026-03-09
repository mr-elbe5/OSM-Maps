/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class SettingsViewController: PopoverViewController {
    
    var contentView: SettingsView{
        view as! SettingsView
    }
    
    override func loadView() {
        view = SettingsView(controller: self)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 0))
        view.setupView()
    }
    
    func clearTiles(){
        showDestructiveApprove(title: "deleteAllTiles".localize(), text: "deleteAllTilesHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
            MainViewController.shared.refreshMap()
        }
    }
    
}

class SettingsView: PopoverView{
    
    var contentController: SettingsViewController{
        controller as! SettingsViewController
    }
    
    var mapSourceControl: NSSegmentedControl!
    
    override func setupView(){
        mapSourceControl = NSSegmentedControl(labels: ["osm".localize(), "elbe5".localize(), "elbe5topo".localize()], trackingMode: .selectOne, target: self, action: #selector(mapSourceChanged))
        let header = NSTextField(labelWithString: "map".localize())
        addSubviewCenteredBelow(header)
        
        mapSourceControl.selectedSegment = MapSourceList.shared.indexOf(source: Settings.shared.mapSource)
        addSubviewBelow(mapSourceControl, upperView: header)
        
        let hint = NSTextField(wrappingLabelWithString: "mapServerHint".localize(table: "Hints")).asSmallLabel()
        addSubviewBelow(hint, upperView: mapSourceControl)
        
        let clearTileCacheButton = NSButton(title: "clearMapCache".localize(), target: self, action: #selector(clearTiles))
        addSubviewBelow(clearTileCacheButton, upperView: hint)
            .connectToBottom(of: self)
    }
    
    @objc func mapSourceChanged(){
        switch mapSourceControl.indexOfSelectedItem {
        case 0:
            Settings.shared.mapSource = .osm
        case 1:
            Settings.shared.mapSource = .elbe5
        case 2:
            Settings.shared.mapSource = .elbe5Topo
        default:
            break
        }
        Settings.shared.save()
    }
    
    @objc func clearTiles(){
        contentController.clearTiles()
    }
    
}
