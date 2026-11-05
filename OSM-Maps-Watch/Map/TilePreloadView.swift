//
//  MapSettingsView.swift
//  OSM Maps
//
//  Created by miro on 05.11.26.
//


/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI
import OSLog

struct TilePreloadView: View {
    
    @State var settings = Settings.shared
    @State var maxZoom:Int = 0
    @State var preloader = MapPreloader()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("preloadTiles".localize()).font(Font.headline)
                Spacer(minLength: 20)
                Picker("maxZoom".localizeWithColon(), selection: $maxZoom) {
                    // zoom from 8 .. 16
                    ForEach(0..<9) { i in
                        Text(String(i + 8))
                    }
                }
                .pickerStyle(.navigationLink)
                .onChange(of: maxZoom) { oldValue, newValue in
                    setTileGrid()
                }
                Text("allTiles".localize() + ":" + String(preloader.allPreloadTiles))
                Text("existingTiles".localize() + ":" + String(preloader.existingTiles))
                Spacer(minLength: 20)
                Button("startPreload".localize(), action:{
                    if !preloader.startDownload(){
                        print("download failed")
                    }
                })
                Button("cancelPreload".localize(), action:{
                    preloader.cancelDownload()
                })
                Spacer(minLength: 20)
                Button("clearMapTiles".localize(), action: {
                    TileProvider.shared.resetTileDirectories()
                    })
                    .foregroundStyle(.red)
            }
        }
    }
    
    func setTileGrid(){
        let coordinateRegion = WatchMapStatus.shared.coordinateRegion
        let tileRegion = TileRegion(coordinateRegion: coordinateRegion, minZoom: World.minZoom, maxZoom: 8 + maxZoom)
        preloader.setTileRegion(tileRegion)
    }
}

#Preview {
    MapSettingsView()
}
