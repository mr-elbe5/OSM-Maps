/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import SwiftUI

struct WatchTrackView: View {
    
    @State var trackStatus = TrackStatus.shared
    @State var preferences = Preferences.shared
    
    @State private var showDeleteAlert = false
    
    var body: some View {
            VStack(){
                Text("recordTrack".localize()).font(Font.headline)
                Spacer()
                if !trackStatus.isTracking{
                    Button("start".localize(), action: {
                        TrackRecorder.shared.startTrack()
                    })
                    Spacer()
                }
                else{
                    if trackStatus.isRecording{
                        HStack{
                            Button("stop".localize(), action: {
                                TrackRecorder.shared.stopRecording()
                            })
                        }
                        
                    }
                    else {
                        VStack{
                            HStack{
                                Button("resume".localize(), action: {
                                    TrackRecorder.shared.resumeRecording()
                                })
                            }
                            HStack{
                                Button("save".localize(), action: {
                                    TrackRecorder.shared.saveTrack()
                                })
                                .tint(.green)
                                Button("delete".localize(), action: {
                                    showDeleteAlert = true
                                    
                                })
                                .tint(.red)
                                .alert("reallyDeleteTrack".localize(), isPresented: $showDeleteAlert) {
                                    Button("yes".localize()) {
                                        TrackRecorder.shared.cancelTracking()
                                    }
                                    Button("no".localize()) {
                                    }
                                }
                            }
                        }
                        
                    }
                    Spacer()
                    HStack{
                        Text("\("duration".localize()): \(trackStatus.durationString)")
                    }
                    HStack{
                        Text("\("distance".localize()): \(trackStatus.coveredDistance) m")
                    }
                    if preferences.countTrackpoints{
                        HStack{
                            Text("\("trackpoints".localize()): \(trackStatus.trackpointCount)")
                        }
                    }
                }
    
                
        }
        
        
    }
    
}

#Preview {
    WatchTrackView()
}
