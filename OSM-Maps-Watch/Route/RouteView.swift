/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct RouteView: View{
    
    @State var mapStatus = WatchMapStatus.shared
    
    //@State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var route: Route
    var size: CGSize
    
    var body: some View{
        Canvas { context, size in
            let points = mapStatus.getScreenPoints(route.trackpoints, size: size)
            var path = Path()
            path.addLines(points)
            context.stroke(path, with: .color(.blue), lineWidth: 3)
        }
        .offset(x: mapStatus.dragOffset.width, y: mapStatus.dragOffset.height)
        .gesture(DragGesture()
            .onChanged { gesture in
                mapStatus.dragOffset = gesture.translation
                mapStatus.currentLocationOffset.width += mapStatus.dragOffset.width - lastOffset.width
                mapStatus.currentLocationOffset.height += mapStatus.dragOffset.height - lastOffset.height
                lastOffset = mapStatus.dragOffset
            }
            .onEnded { _ in
                mapStatus.moveBy(offset: mapStatus.dragOffset)
                mapStatus.dragOffset = .zero
                lastOffset = .zero
                Preferences.shared.followLocation = false
            }
        )
    }
    
}
