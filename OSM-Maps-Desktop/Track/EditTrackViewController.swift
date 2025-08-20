/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

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
            newItem.track.trackpoints.append(Trackpoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        menuView = EditTrackMenuView()
        mapView = EditTrackMapView(track: newItem)
        trackpointDetailView = EditTrackpointDetailView()
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        //view.window?.makeFirstResponder(nil)
    }
    
    func updateTrackpointDetailView(){
        var trackpoint: Trackpoint? = nil
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
        var list = TrackpointList()
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
                return tp.id == tp1.id
            })
        })
        newItem.trackpointsChanged()
        mapView.trackpointsChanged()
        updateTrackpointDetailView()
    }
    
    func undoTrackChanges(){
        newItem.track.trackpoints.removeAll()
        for tp in item.track.trackpoints{
            newItem.track.trackpoints.append(Trackpoint(coordinate: tp.coordinate, altitude: tp.altitude, timestamp: tp.timestamp))
        }
        newItem.trackpointsChanged()
        mapView.trackpointsChanged()
    }
    
}

extension EditTrackViewController: EditTrackMapDelegate{
    
    func trackpointChangedInMap(_ trackpoint: Trackpoint) {
        updateTrackpointDetailView()
    }
    
}
