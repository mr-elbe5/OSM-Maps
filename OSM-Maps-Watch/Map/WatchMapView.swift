/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct MapView: View {
    
    @State var settings = Settings.shared
    @State var mapStatus = WatchMapStatus.shared
    
    var body: some View {
        ZStack(alignment: .center){
            VStack(alignment: .center, spacing: 0){
                ForEach(0..<mapStatus.gridHeight, id: \.self){ y in
                    HStack(alignment: .center, spacing: 0){
                        ForEach(0..<mapStatus.gridWidth, id: \.self){ x in
                            ZStack{
                                if let image = getImage(x, y){
                                    Image(uiImage: image)
                                        .frame(width: World.tileExtent, height: World.tileExtent)
                                }
                                else{
                                    Image("gear.grey")
                                        .resizable()
                                        .frame(width: World.tileExtent, height: World.tileExtent)
                                }
                                if settings.showOverlay, settings.hasOverlay, let image = getOverlayImage(x, y){
                                    Image(uiImage: image)
                                        .background(.clear)
                                        .frame(width: World.tileExtent, height: World.tileExtent)
                                }
                            }
                        }
                    }
                }
                
            }
            .offset(x: mapStatus.tileOffsetX, y: mapStatus.tileOffsetY)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func getImage(_ x: Int, _ y: Int) -> UIImage?{
        if let tile = mapStatus.getTile(x: x, y: y){
            if let imageData = tile.imageData{
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    func getOverlayImage(_ x: Int, _ y: Int) -> UIImage?{
        if let tile = mapStatus.getOverlayTile(x: x, y: y){
            if let imageData = tile.imageData{
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
}

#Preview {
    MapView()
}
