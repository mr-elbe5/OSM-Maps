/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct AccuracyView: View {
    
    @State var locationStatus = WatchLocationStatus.shared
    
    var body: some View {
        HStack(spacing: 3){
            Circle()
                .fill(locationStatus.accuracy < LocationDistance.extraWide.distance ? .blue :.white)
                .frame(width: 10, height: 10)
            Circle()
                .fill(locationStatus.accuracy < LocationDistance.wide.distance ? .blue :.white)
                .frame(width: 10, height: 10)
            Circle()
                .fill(locationStatus.accuracy < LocationDistance.medium.distance ? .blue :.white)
                .frame(width: 10, height: 10)
            Circle()
                .fill(locationStatus.accuracy < LocationDistance.tight.distance ? .blue :.white)
                .frame(width: 10, height: 10)
        }
        .frame(width: 50, height: 10)
    }
    
}

#Preview {
    AccuracyView()
}
