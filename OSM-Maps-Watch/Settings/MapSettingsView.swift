/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI
import OSLog

struct MapSettingsView: View {
    
    @State var settings = Settings.shared
    @State var sourceName:String = Settings.shared.tileSource.displayName
    @State var overlaySources: OverlayTileSources = OverlayTileSources.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("mapSettings".localize()).font(Font.headline)
                Spacer(minLength: 20)
                Picker("tileSource".localizeWithColon(), selection: $sourceName) {
                    ForEach(TileSources.shared, id: \.self.displayName) { option in
                        Text(option.displayName)
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: sourceName) { oldValue, newValue in
                    Logger.debug("source name changed from \(oldValue) to \(newValue)")
                    if let newSource = TileSources.shared.first(where: { $0.displayName == newValue }) {
                        Settings.shared.tileSource = newSource
                        TileProvider.shared.tileSourcesChanged()
                        Logger.debug("set tileSource to \(newSource.name)")
                        Settings.shared.save()
                        MapStatus.shared.tilesLoaded = false
                        MapStatus.shared.updateTiles()
                    }
                }
                Spacer(minLength: 20)
                Text("overlays".localize())
                Spacer(minLength: 10)
                ForEach($overlaySources.indices, id: \.self) { i in
                    Toggle(overlaySources[i].displayName, isOn: $overlaySources[i].active)
                        .onChange(of: overlaySources[i].active){ oldValue, newValue in
                            OverlayTileSources.shared.save()
                            MapStatus.shared.updateTiles()
                        }
                }
                
                Spacer(minLength: 20)
                NavigationLink(destination: TilePreloadView()) {
                    Text("preloadTiles".localize())
                }
                Spacer(minLength: 20)
                Button("clearMapTiles".localize(), action: {
                    TileProvider.shared.resetTileDirectories()
                    })
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    MapSettingsView()
}
