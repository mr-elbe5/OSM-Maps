/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct TileView: View {
    
    var mapTile: MapTile
    
    init(mapTile: MapTile) {
        self.mapTile = mapTile
    }
    
    var body: some View {
        if let image = getImage(){
            Image(osImage: image)
                .resizable()
        }
        else{
            Image("gear.grey")
                .resizable()
        }
    }
    
    func getImage() -> OSImage?{
        if let imageData = mapTile.imageData{
            return OSImage(data: imageData)
        }
        return nil
    }
    
}
    
