/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct RouteView: View{
    
    @State var mapStatus = WatchMapStatus.shared
    
    var route: Route
    var size: CGSize
    
    var body: some View{
        Canvas { context, size in
            let points = mapStatus.getScreenPoints(route.trackpoints, size: size)
            var path = Path()
            path.addLines(points)
            context.stroke(path, with: .color(.blue), lineWidth: 3)
        }
    }
    
}
