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
        .gesture(DragGesture()
            .onChanged { gesture in
                Preferences.shared.followLocation = false
                let dragOffset = gesture.translation
                let diff = CGSize(width: dragOffset.width - lastOffset.width, height: dragOffset.height - lastOffset.height)
                mapStatus.moveBy(offset: diff)
                lastOffset = dragOffset
            }
            .onEnded { _ in
                lastOffset = .zero
            }
        )
    }
    
}

