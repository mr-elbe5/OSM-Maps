/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

protocol PreferencesDelegate{
    func clearTiles()
}

class PreferencesViewController: ModalViewController, PreferencesDelegate {
    
    var contentView = PreferencesView()
    
    override func loadView() {
        super.loadView()
        view.addSubviewFilling(contentView)
        contentView.setupView()
        contentView.delegate = self
    }
    
    func clearTiles(){
        showDestructiveApprove(title: "deleteAllTiles".localize(), text: "deleteAllTilesHint".localize(table: "Hints")){
            TileProvider.shared.deleteAllTiles()
            MainViewController.shared.refreshMap()
        }
    }
    
    class PreferencesView: NSView{
        
        var mapSourceControl: NSSegmentedControl!
        
        var delegate: PreferencesDelegate? = nil
        
        init() {
            super.init(frame: .zero)
            mapSourceControl = NSSegmentedControl(labels: ["osm".localize(), "elbe5".localize(), "elbe5topo".localize()], trackingMode: .selectOne, target: self, action: #selector(mapSourceChanged))
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setupView() {
            
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
            delegate?.clearTiles()
        }
        
    }
    
}
