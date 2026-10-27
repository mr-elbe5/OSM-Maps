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
                if checkStatus(){
                    ForEach(0..<mapStatus.gridHeight, id: \.self){y in
                        HStack(alignment: .center, spacing: 0){
                            ForEach(0..<mapStatus.gridWidth, id: \.self){ x in
                                ZStack{
                                    TileView(tile: mapStatus.getTile(x: x, y: y))
                                }
                            }
                        }
                    }
                }
            }
            .offset(x: mapStatus.tileOffset.x, y: mapStatus.tileOffset.y)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func checkStatus() -> Bool{
        print("check")
        mapStatus.checkStatus()
        return true
    }
    
}

#Preview {
    MapView()
}
