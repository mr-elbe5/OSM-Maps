/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct MapLinesCanvas: View{
    
    @State var mapStatus = WatchMapStatus.shared
    @State var routeStatus = RouteStatus.shared
    @State var trackStatus = TrackStatus.shared
    
    @State private var lastOffset = CGSize.zero
    
    var size: CGSize
    
    var body: some View{
        Canvas { context, size in
            if trackStatus.isTracking, let track = TrackRecorder.shared.track {
                let points = mapStatus.getScreenPoints(track.trackpoints, size: size)
                var path = Path()
                path.addLines(points)
                context.stroke(path, with: .color(.yellow), lineWidth: 3)
            }
            if let route = routeStatus.route, routeStatus.visible{
                let points = mapStatus.getScreenPoints(route.trackpoints, size: size)
                var path = Path()
                path.addLines(points)
                context.stroke(path, with: .color(.blue), lineWidth: 3)
            }
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
