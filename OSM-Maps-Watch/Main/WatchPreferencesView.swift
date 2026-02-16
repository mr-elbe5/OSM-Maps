/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct WatchPreferencesView: View {
    
    @State var preferences = Preferences.shared
    @State var phoneConnector = PhoneConnector.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("preferences".localize()).font(Font.headline)
                Spacer(minLength: 20)
                Picker("mapServer".localizeWithColon(), selection: $preferences.mapSource) {
                    ForEach(MapSource.allCases) { option in
                        Text("\(option.rawValue)_server".localize())
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: preferences.mapSource) { oldValue, newValue in
                    preferences.save()
                }
                Spacer(minLength: 20)
                Toggle(isOn: $preferences.showCurrentLocation) {
                    Text("showCurrentLocation".localize())
                    }
                .onChange(of: preferences.showCurrentLocation) { oldValue, newValue in
                    preferences.save()
                }
                Spacer()
                Toggle(isOn: $preferences.showDirection) {
                    Text("showDirection".localize())
                    }
                .onChange(of: preferences.showDirection) { oldValue, newValue in
                    preferences.save()
                    LocationService.shared.updateShowDirection()
                }
                Spacer()
                Toggle(isOn: $preferences.followLocation) {
                    Text("followLocation".localize())
                    }
                .onChange(of: preferences.followLocation) { oldValue, newValue in
                    preferences.save()
                }
                Toggle(isOn: $preferences.showHeartRate) {
                    Text("showHeartrate".localize())
                    }
                .onChange(of: preferences.showHeartRate) { oldValue, newValue in
                    preferences.save()
                }
                Spacer(minLength: 20)
                Toggle(isOn: $preferences.countTrackpoints) {
                    Text("countTrackpoints".localize())
                    }
                .onChange(of: preferences.countTrackpoints) { oldValue, newValue in
                    preferences.save()
                }
                Spacer(minLength: 20)
                Picker("trackpointInterval".localizeWithColon(), selection: $preferences.trackpointInterval) {
                    ForEach(TrackpointInterval.allCases) { option in
                        Text("\(option.rawValue)s")
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: preferences.trackpointInterval) { oldValue, newValue in
                    preferences.save()
                }
                Text("trackpointIntervalHint".localize(table: "Hints"))
                    .hint()
                Picker("distanceFilter".localizeWithColon(), selection: $preferences.distanceFilter) {
                    ForEach(LocationDistance.allCases) { option in
                        if option == .gps{
                            Text("gpsAccuracy".localize())
                        }
                        else{
                            Text("\(option.rawValue)m")
                        }
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: preferences.distanceFilter) { oldValue, newValue in
                    LocationService.shared.updateDistanceFilter()
                    preferences.save()
                }
                Text("distanceFilterHint".localize(table: "Hints"))
                    .hint()
                Spacer(minLength: 20)
                HStack{
                    Button("testConnection".localize()) {
                        phoneConnector.requestConnection()
                    }
                    .foregroundColor(.blue)
                    Spacer()
                    switch phoneConnector.connectionState{
                    case .connectionEstablished:
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    case .connectionFailed:
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                    case .connectionNotTested:
                        Image(systemName: "questionmark")
                            .foregroundColor(.yellow)
                    }
                }
                Spacer(minLength: 20)
                Button("clearMapTiles".localize(), action: {
                        TileProvider.shared.deleteAllTiles()
                    })
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    WatchPreferencesView()
}
