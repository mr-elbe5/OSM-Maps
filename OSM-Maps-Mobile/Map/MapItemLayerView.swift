/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import OSLog

class MapItemLayerView: UIView {
    
    func setupMarkerViews(zoom: Int, offset: CGPoint, scale: CGFloat){
        //Logger.debug("setupMarkerViews, zoom=\(zoom),offset=\(offset),scale=\(scale)")
        for subview in subviews {
            subview.removeFromSuperview()
        }
        let planetDist = World.upScale(from: zoom) * MarkerView.baseFrame.width/2
        var groups = Array<MapItemGroup>()
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
                let marker = GroupMarkerView(itemGroup: group)
                marker.addAction(UIAction{ action in
                    let controller = ItemListViewController(title: "items".localize())
                    controller.loadItems(group.items)
                    MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
                }, for: .touchDown)
                addSubview(marker)
            }
            else if let item = group.items.first{
                let marker = ItemMarkerView(item: item)
                marker.addAction(UIAction{ action in
                    let controller = ItemListViewController(title: "items".localize())
                    controller.loadItems([item])
                    MainViewController.shared.navigationController?.pushViewController(controller, animated: true)
                }, for: .touchDown)
                addSubview(marker)
            }
        }
        updatePosition(offset: offset, scale: scale)
    }
    
    func getMarker(item: MapItem) -> MarkerView?{
        for subview in subviews{
            if let marker = subview as? ItemMarkerView, marker.item.id == item.id{
                return marker
            }
            if let marker = subview as? GroupMarkerView, marker.group.items.contains(where: {$0.id == item.id}){
                return marker
            }
        }
        return nil
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            $0 is MarkerView && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }
    
    func updatePosition(offset: CGPoint, scale: CGFloat){
        let offset = CGPoint(x: offset.x/scale, y: offset.y/scale).normalizedPoint
        for subview in subviews{
            if let marker = subview as? ItemMarkerView{
                let mapPoint = marker.item.worldPoint
                marker.updatePosition(to: CGPoint(x: (mapPoint.x - offset.x)*scale , y: (mapPoint.y - offset.y)*scale))
            }
            else if let groupMarker = subview as? GroupMarkerView, let mapPoint = groupMarker.group.centerWorldPoint{
                groupMarker.updatePosition(to: CGPoint(x: (mapPoint.x - offset.x)*scale , y: (mapPoint.y - offset.y)*scale))
            }
        }
    }
    
    func updateItemStatus(_ item: MapItem){
        if let marker = getMarker(item: item){
            marker.updateImage()
        }
    }
    
}



