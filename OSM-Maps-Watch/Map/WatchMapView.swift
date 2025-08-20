/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct MapView: View {
    
    @State var preferences = Preferences.shared
    @State var mapStatus = WatchMapStatus.shared
    
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var body: some View {
        ZStack(alignment: .center){
            VStack(alignment: .center, spacing: 0){
                ForEach(0..<mapStatus.gridHeight, id: \.self){ y in
                    HStack(alignment: .center, spacing: 0){
                        ForEach(0..<mapStatus.gridWidth, id: \.self){ x in
                            if let image = getImage(x, y){
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
                }
                
            }
            .offset(x: mapStatus.tileOffsetX + offset.width, y: mapStatus.tileOffsetY + offset.height)
            .gesture(DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    mapStatus.currentLocationOffset.width += offset.width - lastOffset.width
                    mapStatus.currentLocationOffset.height += offset.height - lastOffset.height
                    lastOffset = offset
                }
                .onEnded { _ in
                    mapStatus.moveBy(offset: offset)
                    offset = .zero
                    lastOffset = .zero
                    Preferences.shared.followLocation = false
                }
            )
            
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
    
}

#Preview {
    MapView()
}
