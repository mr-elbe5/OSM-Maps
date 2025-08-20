/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import SwiftUI
import CoreLocation

struct WatchLocationView: View {
    
    @State var mapStatus = WatchMapStatus.shared
    @State var preferences = WatchPreferences.shared
    
    let currentDirectionColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.blue, lineWidth: 2)
                .frame(width: 20, height: 20)
            Circle()
                .fill(Color(.blue))
                .frame(width: 8, height: 8)
            if preferences.showDirection{
                Triangle(direction: $mapStatus.direction)
                    .fill(currentDirectionColor)
                    .frame(width: 30, height: 30)
            }
        }
        .frame(width: 30, height: 30)
    }
    
}

struct Triangle: Shape {
    
    let locationRadius : CGFloat = 15
    
    @Binding var direction: CLLocationDirection
    
    func path(in rect: CGRect) -> Path {
        let centerX = rect.midX
        let centerY = rect.midY
        let angle1 = (direction - 15)*CGFloat.pi/180
        let angle2 = (direction + 15)*CGFloat.pi/180
        var path = Path()
        path.move(to: CGPoint(x: centerX, y: centerY))
        path.addLine(to: CGPoint(x: centerX + locationRadius * sin(angle1), y: centerY - locationRadius * cos(angle1)))
        path.addLine(to: CGPoint(x: centerX + locationRadius * sin(angle2), y: centerY - locationRadius * cos(angle2)))
        return path
    }
}

#Preview {
    WatchLocationView()
}
