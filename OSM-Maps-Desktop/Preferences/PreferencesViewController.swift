/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class PreferencesViewController: PopoverViewController {
    
    override func loadView() {
        view = NSView()
        view.addSubviewFilling(PreferencesView(controller: self))
    }
    
    func clearTiles(){
        showDestructiveApprove(title: "deleteAllTiles".localize(), text: "deleteAllTilesHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
            MainViewController.shared.refreshMap()
        }
    }
    
    class PreferencesView: NSView{
        
        var controller: PreferencesViewController
        
        var mapSourceControl: NSSegmentedControl!
        
        init(controller: PreferencesViewController) {
            self.controller = controller
            super.init(frame: .zero)
            mapSourceControl = NSSegmentedControl(labels: ["osm".localize(), "elbe5".localize(), "elbe5topo".localize()], trackingMode: .selectOne, target: self, action: #selector(mapSourceChanged))
            let header = NSTextField(labelWithString: "map".localize())
            addSubviewCenteredBelow(header)
        
            mapSourceControl.selectedSegment = MapSourceList.shared.indexOf(source: Preferences.shared.mapSource)
            addSubviewBelow(mapSourceControl, upperView: header)
            
            let hint = NSTextField(wrappingLabelWithString: "mapServerHint".localize(table: "Hints")).asSmallLabel()
            addSubviewBelow(hint, upperView: mapSourceControl)
            
            let clearTileCacheButton = NSButton(title: "clearMapCache".localize(), target: self, action: #selector(clearTiles))
            addSubviewBelow(clearTileCacheButton, upperView: hint)
                .connectToBottom(of: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc func mapSourceChanged(){
            switch mapSourceControl.indexOfSelectedItem {
            case 0:
                Preferences.shared.mapSource = .osm
            case 1:
                Preferences.shared.mapSource = .elbe5
                case 2:
                Preferences.shared.mapSource = .elbe5Topo
            default:
                break
            }
            Preferences.shared.save()
        }
        
        @objc func clearTiles(){
            controller.clearTiles()
        }
        
    }
    
}
