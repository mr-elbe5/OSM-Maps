/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct WatchMainView: View {
    
    @State var trackRecorder = TrackRecorder.shared
    @State var routeStatus = RouteStatus.shared
    @State var healthStatus = WatchHealthStatus.shared
    @State var preferences = Preferences.shared
    @State var mapStatus = WatchMapStatus.shared
    @State var zoomLevel: CGFloat = CGFloat(WatchMapStatus.shared.zoom)
    
    var body: some View {
        GeometryReader{ proxy in
            WatchMapStatus.shared.screenSize = proxy.frame(in: .global)
            return ZStack(){
                MapView()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .background(.secondary)
                    .clipped()
                    .focusable()
                if let route = routeStatus.route{
                    RouteView(route: route, size: proxy.size)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(.clear)
                        .clipped()
                }
                if preferences.showCurrentLocation{
                    WatchLocationView()
                        .offset(mapStatus.currentLocationOffset)
                }
                AccuracyView()
                    .position(x: 30, y: 15)
                    
                if preferences.showHeartRate, healthStatus.isMonitoring{
                    Text("❤️")
                        .font(.system(size: 12))
                        .offset(y: -proxy.size.height/2 + 20)
                    Text("\(Int(healthStatus.heartRate))")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .offset(x: 20, y: -proxy.size.height/2 + 20)
                }
                if preferences.showCurrentLocation {
                    Image(systemName: "triangle.bottomhalf.filled")
                        .foregroundColor(.black)
                        .offset(y: proxy.size.height/2 - 20)
                    Text("\(Int(LocationStatus.shared.location.altitude)) m")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .offset(x: 35, y: proxy.size.height/2 - 18)
                }
                if !preferences.followLocation{
                    Button(action: {
                        Preferences.shared.followLocation = true
                        WatchMapStatus.shared.locationChanged(to: LocationStatus.shared.location)
                    }) {
                        Image(systemName: "record.circle")
                    }
                    .mapButton()
                    .position(x: proxy.size.width - 20, y: proxy.size.height/2)
                }
                NavigationLink(destination: WatchPreferencesView()) {
                    Image(systemName: "gear")
                }
                .mapButton()
                .position(x: proxy.size.width - 20, y: 20)
                NavigationLink(destination: WatchTrackView()) {
                    Image(systemName: trackRecorder.isTracking ? "figure.walk" : "figure.stand")
                }
                .mapButton()
                .position(x: proxy.size.width - 20, y: proxy.size.height - 20)
                if routeStatus.route != nil{
                    NavigationLink(destination: WatchRouteControlView()) {
                        Image(systemName: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath")
                    }
                    .mapButton()
                    .position(x: 20, y: proxy.size.height - 20)
                }
            }
            .clipped()
            .frame(maxWidth: .infinity)
        }
        .digitalCrownRotation($zoomLevel, from: CGFloat(World.minZoom), through: CGFloat(World.maxZoom), sensitivity: .low)
        .onChange(of: zoomLevel, initial: false ) {
            MapStatus.shared.zoomTo(Int(zoomLevel))
        }
    }
        
}

#Preview {
    NavigationStack(){
        WatchMainView()
    }
}
