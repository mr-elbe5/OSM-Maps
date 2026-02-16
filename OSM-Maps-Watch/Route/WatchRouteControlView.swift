/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct WatchRouteControlView: View {
    
    @State var routeStatus = RouteStatus.shared
    @State var preferences = Preferences.shared
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(){
                Text("route".localize()).font(Font.headline)
                Spacer()
                if let route = routeStatus.route {
                    ForEach(route.routepoints.indices, id: \.self) { index in
                        RoutepointView(routepoint: route.routepoints[index])
                    }
                    Spacer()
                    Button(routeStatus.visible ? "hide".localize() : "show".localize(), action: {
                        routeStatus.toggleVisible()
                    })
                    Spacer()
                    Button("delete".localize(), action: {
                        routeStatus.removeRoute()
                        routeStatus.save()
                    })
                }
            }
        }
    }
    
}

struct RoutepointView: View {
    var routepoint: Routepoint
    var body: some View {
        if routepoint.iconName.isEmpty{
            Text(routepoint.directionString)
        }
        else{
            HStack(alignment: .center){
                Image(systemName: routepoint.iconName)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.secondary)
                Text(routepoint.directionString)
            }
        }
        if routepoint.distance > 0{
            Text("\("after".localize()) \(routepoint.distance)m:")
        }
    }
}

#Preview {
    WatchTrackControlView()
}
