/*
 OSM Maps (Mac)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

protocol ClickDelegate{
    func clicked(with event: NSEvent)
}

protocol DragDelegate{
    func mouseDragged(dx: CGFloat, dy: CGFloat)
}

class ItemLayerView: LayerView {
    
    var clickDelegate: ClickDelegate? = nil
    var dragDelegate: DragDelegate? = nil
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool{
        return false
    }
    
    override func mouseDown(with event: NSEvent) {
        clickDelegate?.clicked(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        if event.type == .leftMouseDragged{
            dragDelegate?.mouseDragged(dx: event.deltaX, dy: event.deltaY)
        }
    }
    
    override func updatePosition(scale: CGFloat){
        self.scale = scale
        for subview in subviews{
            if let marker = subview as? ItemMarkerView{
                let mapPoint = marker.item.worldPoint
                marker.updatePosition(to: CGPoint(x: mapPoint.x*scale , y: mapPoint.y*scale))
            }
            else if let groupMarker = subview as? GroupMarker, let mapPoint = groupMarker.group.centerWorldPoint{
                groupMarker.updatePosition(to: CGPoint(x: mapPoint.x*scale , y: mapPoint.y*scale))
            }
        }
        needsDisplay = true
    }
    
    override func updateContent(scale: CGFloat){
        //Log.debug("updateContent")
        self.scale = scale
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if !Preferences.shared.showMapPins{
            return
        }
        let planetDist = 1.0/scale * MarkerView.size/2.0 //have no markers overlap
        var groups = [MapItemGroup]()
        for item in AppData.shared.mapItems{
            if !item.hasValidCoordinate{
                continue
            }
            var grouped = false
            for group in groups{
                if group.isWithinRadius(item: item, radius: planetDist){
                    group.addItem(item)
                    group.setCenter()
                    grouped = true
                }
            }
            if !grouped{
                let group = MapItemGroup()
                group.addItem(item)
                group.setCenter()
                groups.append(group)
            }
        }
        for group in groups{
            if group.items.count > 1{
                let marker = GroupMarker(itemGroup: group, target: self, action: #selector(showGroupDetails))
                addSubview(marker)
            }
            else if let item = group.items.first{
                let marker = ItemMarkerView(item: item, target: self, action: #selector(showItemDetails))
                addSubview(marker)
            }
        }
        updatePosition(scale: scale)
    }
    
    func getMarker(item: MapItem) -> MarkerView?{
        for subview in subviews{
            if let marker = subview as? ItemMarkerView, marker.item.id == item.id{
                return marker
            }
            if let marker = subview as? GroupMarker, marker.group.items.contains(where: {$0.id == item.id}){
                return marker
            }
        }
        return nil
    }
    
    func updateItemStatus(_ item: MapItem){
        if let marker = getMarker(item: item){
            marker.updateImage()
        }
    }
    
    @objc func showItemDetails(sender: AnyObject?){
        if let marker = sender as? ItemMarkerView{
            MainViewController.shared.showItemDetails(item: marker.item)
        }
    }
    
    @objc func showGroupDetails(sender: AnyObject?){
        if let marker = sender as? GroupMarker{
            MainViewController.shared.showGroupDetails(group: marker.group)
        }
    }
    
}




