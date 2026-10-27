/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct TileView: View {
    
    @State var tile: Tile = .zero
    
    var body: some View {
        if let imageData = tile.imageData, let image = UIImage(data: imageData){
            Image(uiImage: image)
                .frame(width: World.tileExtent, height: World.tileExtent)
        }
        else{
            Image("gear.grey")
                .resizable()
                .frame(width: World.tileExtent, height: World.tileExtent)
        }
    }
        
}

#Preview {
    TileView()
}
