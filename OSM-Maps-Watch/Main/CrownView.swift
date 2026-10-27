/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct CrownView: View {
    
    @State var zoomLevel: CGFloat = CGFloat(WatchMapStatus.shared.zoom)
    
    var body: some View {
        Color.clear
            .frame(width: 0, height: 0, alignment: .topTrailing)
        .focusable()
        .digitalCrownRotation($zoomLevel, from: CGFloat(World.minZoom), through: CGFloat(World.maxZoom), sensitivity: .low, onChange: { evt in
            MapStatus.shared.zoomTo(Int(zoomLevel))
        })
    }
        
}

#Preview {
    CrownView()
}
