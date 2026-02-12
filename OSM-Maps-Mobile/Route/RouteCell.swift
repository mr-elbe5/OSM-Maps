/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit

protocol RouteCellDelegate: MapItemCellDelegate {
}

class RouteCell: MapItemCell{

    static let CELL_IDENT = "routeCell"
    
    var item : RouteItem? = nil
    
    var delegate : RouteCellDelegate? = nil
    
    override func updateIconView(){
        iconView.removeAllSubviews()
        if let route = item{
            let selectedButton = UIButton().asDarkIconButton(route.selected ? "checkmark.square" : "square")
            selectedButton.addAction(UIAction(){ action in
                route.selected = !route.selected
                selectedButton.setImage(UIImage(systemName: route.selected ? "checkmark.square" : "square"), for: .normal)
                self.delegate?.selectionChanged()
            }, for: .touchDown)
            iconView.addSubviewToLeft(selectedButton, insets: iconInsets)
            
            let exportButton = UIButton().asDarkIconButton("square.and.arrow.up")
            exportButton.addAction(UIAction(){ action in
                if let route = self.item?.route, let url = route.createGPXFile(){
                    let controller = UIDocumentPickerViewController(forExporting: [url], asCopy: false)
                    controller.delegate = nil
                    MainViewController.shared.present(controller, animated: true)
                }
            }, for: .touchDown)
            iconView.addSubviewToLeft(exportButton, rightView: selectedButton, insets: iconInsets)
            
            let mapButton = UIButton().asDarkIconButton("map")
            mapButton.addAction(UIAction(){ action in
                MainViewController.shared.showRouteOnMap(item: route)
                MainViewController.shared.navigationController?.popViewController(animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(mapButton, rightView: exportButton, insets: iconInsets)
            let viewButton = UIButton().asDarkIconButton("magnifyingglass")
            viewButton.addAction(UIAction(){ action in
                MainViewController.shared.navigationController?.pushViewController(RouteViewController(route: route), animated: true)
            }, for: .touchDown)
            iconView.addSubviewToLeft(viewButton, rightView: mapButton, insets: iconInsets)
                .connectToLeft(of: iconView)
        }
    }
    
    override func updateItemView(){
        itemView.removeAllSubviews()
        if let item = item{
            let header = UILabel(header: "route".localize())
            itemView.addSubviewCenteredBelow(header)
            
            let nameLabel = UILabel(text: item.route.name)
            nameLabel.textAlignment = .center
            itemView.addSubviewBelow(nameLabel, upperView: header)
            
            var rp = item.route.trackpoints.isEmpty ? nil : item.route.trackpoints.first
            var str = item.startLocation?.flatAddress ?? rp?.coordinate.asString ?? ""
            let startLabel = UILabel(text: "\("start".localize()): \(str)")
            itemView.addSubviewBelow(startLabel, upperView: nameLabel)
            
            rp = item.route.trackpoints.isEmpty ? nil : item.route.trackpoints.last
            str = item.endLocation?.flatAddress ?? rp?.coordinate.asString ?? ""
            let endLabel = UILabel(text: "\("end".localize()): \(str)")
            itemView.addSubviewBelow(endLabel, upperView: startLabel, insets: OSInsets.flatInsets)
            
            let distanceLabel = UILabel(text: "\("distance".localize()): \(Int(item.route.distance)) m")
            itemView.addSubviewBelow(distanceLabel, upperView: endLabel, insets: OSInsets.flatInsets)
            
            let typeLabel = UILabel(text: "\("routeType".localize()): \(("routeType_" + item.route.type.rawValue).localize())")
            itemView.addSubviewBelow(typeLabel, upperView: distanceLabel)
            
            let durationLabel = UILabel(text: "\("duration".localize()): \(item.route.duration.hmsString())")
            itemView.addSubviewBelow(durationLabel, upperView: typeLabel, insets: OSInsets.flatInsets)
            
            if let image = item.getPreview(){
                let imageView = UIImageView()
                imageView.withDefaults()
                imageView.setRoundedBorders()
                imageView.image = image
                imageView.setAspectRatioConstraint()
                imageView.contentMode = .scaleAspectFit
                itemView.addSubviewBelow(imageView, upperView: durationLabel)
                    .connectToBottom(of: itemView)
            }
            else{
                let btn = TextButton(text: "loadPreview".localize(), tintColor: .darkColor, withBorder: false)
                btn.addAction(UIAction(){ action in
                    if RouteImageCreator.createPreview(item: item) != nil{
                        DispatchQueue.main.async {
                            self.updateItemView()
                        }
                    }
                }, for: .touchDown)
            }
        }
    }
    
    override func setupTimeLabel(){
        timeLabel.text = item?.creationDate.dateTimeString()
    }
    
    override func setupMapIcon() {
        mapIconView.image = MapDefaults.routeStartIcon
    }
    
}

extension RouteCell: UITextFieldDelegate{
    
    func textFieldDidChange(_ textField: UITextView) {
        if let item = item{
            item.route.name = textField.text
        }
    }
    
}
