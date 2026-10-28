/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct MapView: View {
    
    @State var settings = Settings.shared
    @State var mapStatus = WatchMapStatus.shared
    @State var overlaySources: OverlayTileSources = Settings.shared.overlayTileSources
    
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
                                ForEach(0..<mapStatus.overlayGrids.count, id: \.self){ option in
                                    if let image = getOverlayImage(option, x, y){
                                        Image(uiImage: image)
                                            .background(.clear)
                                            .frame(width: World.tileExtent, height: World.tileExtent)
                                    }
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
    
    func getOverlayImage(_ idx: Int, _ x: Int, _ y: Int) -> UIImage?{
        //print("get overlay tile")
        if let tile = mapStatus.getOverlayTile(idx: idx, x: x, y: y){
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
