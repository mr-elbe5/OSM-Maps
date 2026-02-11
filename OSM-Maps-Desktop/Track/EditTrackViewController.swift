/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

protocol EditTrackDelegate {
    func trackChanged(item: TrackItem)
}

class EditTrackViewController: ModalViewController {
    
    var startSize = CGSize(width: 1000, height: 800)
    
    var item: TrackItem
    var newItem = TrackItem()
    
    var menuView: EditTrackMenuView
    var mapView: EditTrackMapView
    var trackpointDetailView: EditTrackpointDetailView
    var nameEditField = NSTextField()
    var minDistanceField = NSTextField()
    
    init(item: TrackItem){
        self.item = item
        for tp in item.track.trackpoints{
            newItem.track.addTrackpoint(MapPoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        menuView = EditTrackMenuView()
        mapView = EditTrackMapView(track: newItem)
        trackpointDetailView = EditTrackpointDetailView()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        item.track.trackpoints.deselectAll()
    }
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: startSize)
        menuView.setupView()
        menuView.delegate = self
        view.addSubviewWithAnchors(menuView, top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        view.addSubviewWithAnchors(mapView, top: menuView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        trackpointDetailView.setupView()
        view.addSubviewWithAnchors(trackpointDetailView, top: mapView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        
        nameEditField.asEditableField(text: item.track.name)
        view.addSubviewWithAnchors(nameEditField, top: trackpointDetailView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        mapView.delegate = self
        let hintLabel = NSTextField(wrappingLabelWithString: "trackEditorHint".localize(table: "Hints"))
        view.addSubviewWithAnchors(hintLabel, top: nameEditField.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        let simplifyView = NSView()
        view.addSubviewWithAnchors(simplifyView, top: hintLabel.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor)
        let simplifyLabel = NSTextField(labelWithString: "simplifyByDistance".localize())
        simplifyView.addSubviewWithAnchors(simplifyLabel, top: simplifyView.topAnchor, leading: simplifyView.leadingAnchor, bottom: simplifyView.bottomAnchor)
        simplifyView.addSubviewWithAnchors(minDistanceField, top: simplifyView.topAnchor, leading: simplifyLabel.trailingAnchor, bottom: simplifyView.bottomAnchor)
            .width(100)
        let simplifyButton = NSButton(title: "start".localize(), target: self, action: #selector(simplify))
        simplifyView.addSubviewWithAnchors(simplifyButton, top: simplifyView.topAnchor, leading: minDistanceField.trailingAnchor, bottom: simplifyView.bottomAnchor)
        let saveButton = NSButton(title: "save".localize(), target: self, action: #selector(save))
        view.addSubviewWithAnchors(saveButton, top: simplifyView.bottomAnchor, bottom: view.bottomAnchor)
            .centerX(view.centerXAnchor)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.resignFirstResponder()
    }
    
    func updateTrackpointDetailView(){
        var trackpoint: MapPoint? = nil
        for tp in newItem.track.trackpoints{
            if tp.selected{
                if trackpoint == nil{
                    trackpoint = tp
                }
                else{
                    trackpoint = nil
                    break
                }
            }
        }
        trackpointDetailView.setTrackPoint(trackpoint)
    }
    
    @objc func simplify(){
        let dist = Double(minDistanceField.stringValue)
        if let dist = dist, dist > 0{
            newItem.track.setMinimalTrackpointDistances(minDistance: dist)
            mapView.trackpointsChanged()
        }
    }
    
    @objc func save(){
        item.track.name = nameEditField.stringValue
        item.track.setTrackpoints(newItem.track.trackpoints)
        item.trackpointsChanged()
        responseCode = .OK
        view.window?.close()
    }
    
}

extension EditTrackViewController: EditTrackMenuDelegate{
    
    func selectLeading() {
        //Log.debug("select leading")
        let track = newItem.track
        if let idx = track.getSingleSelectedTrackpointIndex(), idx > 0{
            //Log.debug("idx = \(idx)")
            track.selectSingleTrackpoint(at: idx - 1)
        }
        else if !track.trackpoints.isEmpty{
            track.selectSingleTrackpoint(at: track.trackpoints.count - 1)
        }
        newItem.trackpointsChanged()
        mapView.trackpointsChanged()
        updateTrackpointDetailView()
    }
    
    func selectTrailing() {
        //Log.debug("select trailing")
        let track = newItem.track
        if let idx = track.getSingleSelectedTrackpointIndex(), idx < track.trackpoints.count-1{
            //Log.debug("idx = \(idx)")
            track.selectSingleTrackpoint(at: idx + 1)
        }
        else if !track.trackpoints.isEmpty{
            track.selectSingleTrackpoint(at: 0)
        }
        newItem.trackpointsChanged()
        mapView.trackpointsChanged()
        updateTrackpointDetailView()
    }
    
    func insertTrackpointAfter() {
        let track = newItem.track
        if let i = track.getSingleSelectedTrackpointIndex(){
            if i < 0 || i >= track.trackpoints.count-1{
                return
            }
            let tp1 = newItem.track.trackpoints[i]
            let tp2 = newItem.track.trackpoints[i+1]
            let newTp = MapPoint.getMapPointBetween(pnt1: tp1, pnt2: tp2)
            newItem.track.trackpoints.insert(newTp, at: i+1)
            newItem.track.selectSingleTrackpoint(at: i + 1)
            newItem.trackpointsChanged()
            mapView.trackpointsChanged()
            updateTrackpointDetailView()
        }
    }
    
    func insertTrackpointBefore() {
        let track = newItem.track
        if let i = track.getSingleSelectedTrackpointIndex(){
            if i < 1 || i >= track.trackpoints.count{
                return
            }
            let tp1 = newItem.track.trackpoints[i-1]
            let tp2 = newItem.track.trackpoints[i]
            let newTp = MapPoint.getMapPointBetween(pnt1: tp1, pnt2: tp2)
            newItem.track.trackpoints.insert(newTp, at: i)
            newItem.track.selectSingleTrackpoint(at: i)
            newItem.trackpointsChanged()
            mapView.trackpointsChanged()
            updateTrackpointDetailView()
        }
    }
    
    func toggleSelectAllTrackpoints() {
        if newItem.track.trackpoints.allSelected{
            newItem.track.trackpoints.deselectAll()
        }
        else{
            newItem.track.trackpoints.selectAll()
        }
        for sv in mapView.subviews{
            if let marker = sv as? TrackpointMarker{
                marker.needsDisplay = true
            }
        }
        updateTrackpointDetailView()
    }
    
    func deleteSelectedTrackpoints() {
        var list = MapPointList()
        for i in 0..<newItem.track.trackpoints.count{
            let tp = newItem.track.trackpoints[i]
            if tp.selected{
                list.append(tp)
            }
        }
        if list.isEmpty{
            return
        }
        print("deleting \(list.count) trackpoints")
        newItem.track.trackpoints.removeAll(where: { tp in
            list.contains(where: { tp1 in
                return tp == tp1
            })
        })
        newItem.trackpointsChanged()
        mapView.trackpointsChanged()
        updateTrackpointDetailView()
    }
    
    func undoTrackChanges(){
        newItem.track.trackpoints.removeAll()
        for tp in item.track.trackpoints{
            newItem.track.trackpoints.append(MapPoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        newItem.trackpointsChanged()
        mapView.trackpointsChanged()
    }
    
}

extension EditTrackViewController: EditTrackMapDelegate{
    
    func trackpointChangedInMap(_ trackpoint: MapPoint) {
        updateTrackpointDetailView()
    }
    
}
