/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct WatchSettingsView: View {
    
    @State var settings = Settings.shared
    @State var sourceName:String = Settings.shared.tileSource.displayName
    @State var overlaySourceName:String = Settings.shared.overlayTileSource?.displayName ?? "-"
    @State var phoneConnector = PhoneConnector.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("settings".localize()).font(Font.headline)
                Spacer(minLength: 20)
                Picker("tileSource".localizeWithColon(), selection: $sourceName) {
                    ForEach(TileSources.shared, id: \.self.displayName) { option in
                        Text(option.displayName)
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: sourceName) { oldValue, newValue in
                    Log.debug("source name changed from \(oldValue) to \(newValue)")
                    if let newSource = TileSources.shared.first(where: { $0.displayName == newValue }) {
                        Settings.shared.tileSource = newSource
                        Settings.shared.assertTileDirs()
                        Log.debug("set tileSource to \(newSource.name)")
                        Settings.shared.save()
                        MapStatus.shared.tilesLoaded = false
                        MapStatus.shared.updateTiles()
                    }
                }
                Spacer(minLength: 20)
                Picker("overlay".localizeWithColon(), selection: $overlaySourceName) {
                    ForEach(TileSources.sharedOverlays, id: \.self.displayName) { option in
                        Text(option.displayName)
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: overlaySourceName) { oldValue, newValue in
                    Log.debug("overlay source name changed from \(oldValue) to \(newValue)")
                    if let newSource = TileSources.sharedOverlays.first(where: { $0.displayName == newValue }) {
                        Settings.shared.overlayTileSource = newSource
                        Settings.shared.assertTileDirs()
                        Settings.shared.showOverlay = true
                        Log.debug("set overlay tileSource to \(newSource.name)")
                        Settings.shared.save()
                        MapStatus.shared.tilesLoaded = false
                        MapStatus.shared.updateTiles()
                    }
                }
                Toggle(isOn: $settings.showOverlay) {
                    Text("showOverlay".localize())
                    }
                .onChange(of: settings.showOverlay) { oldValue, newValue in
                    Settings.shared.save()
                    MapStatus.shared.tilesLoaded = false
                    MapStatus.shared.updateTiles()
                }
                Spacer(minLength: 20)
                Toggle(isOn: $settings.showCurrentLocation) {
                    Text("showCurrentLocation".localize())
                    }
                .onChange(of: settings.showCurrentLocation) { oldValue, newValue in
                    Settings.shared.save()
                }
                Spacer()
                Toggle(isOn: $settings.showDirection) {
                    Text("showDirection".localize())
                    }
                .onChange(of: settings.showDirection) { oldValue, newValue in
                    Settings.shared.save()
                    LocationService.shared.updateShowDirection()
                }
                Spacer()
                Toggle(isOn: $settings.followLocation) {
                    Text("followLocation".localize())
                    }
                .onChange(of: settings.followLocation) { oldValue, newValue in
                    settings.save()
                }
                Toggle(isOn: $settings.showHeartRate) {
                    Text("showHeartrate".localize())
                    }
                .onChange(of: settings.showHeartRate) { oldValue, newValue in
                    Settings.shared.save()
                }
                Spacer(minLength: 20)
                Toggle(isOn: $settings.countTrackpoints) {
                    Text("countTrackpoints".localize())
                    }
                .onChange(of: settings.countTrackpoints) { oldValue, newValue in
                    Settings.shared.save()
                }
                Spacer(minLength: 20)
                Picker("trackpointInterval".localizeWithColon(), selection: $settings.trackpointInterval) {
                    ForEach(TrackpointInterval.allCases) { option in
                        Text("\(option.rawValue)s")
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: settings.trackpointInterval) { oldValue, newValue in
                    Settings.shared.save()
                }
                Text("trackpointIntervalHint".localize(table: "Hints"))
                    .hint()
                Picker("distanceFilter".localizeWithColon(), selection: $settings.distanceFilter) {
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
                .onChange(of: settings.distanceFilter) { oldValue, newValue in
                    LocationService.shared.updateDistanceFilter()
                    Settings.shared.save()
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
    WatchSettingsView()
}
