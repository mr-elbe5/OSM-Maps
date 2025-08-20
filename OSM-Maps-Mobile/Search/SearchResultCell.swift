/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation

protocol SearchResultCellDelegate{
    func showResult(location: NominatimLocation)
}

class SearchResultCell: UITableViewCell{
    
    static let CELL_IDENT = "searchResultCell"
    
    var location : NominatimLocation? = nil
    
    var delegate: SearchResultCellDelegate? = nil
    
    var cellBody = UIControl()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .systemBackground
        isUserInteractionEnabled = true
        cellBody.addTarget(self, action: #selector(showLocation), for: .touchDown)
        contentView.addSubviewFilling(cellBody)
        accessoryType = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(isEditing: Bool = false){
        cellBody.removeAllSubviews()
        if let location = location{
            let locationLabel = UILabel(text: location.name)
            cellBody.addSubviewWithAnchors(locationLabel, top: cellBody.topAnchor, leading: cellBody.leadingAnchor, trailing: cellBody.trailingAnchor, bottom: cellBody.bottomAnchor)
        }
    }
    
    @objc func showLocation(){
        if let location = location{
            self.delegate?.showResult(location: location)
        }
    }

}


