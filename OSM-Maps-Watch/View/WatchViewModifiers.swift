/*
 OSM Maps (Watch)
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import SwiftUI
import CoreLocation


struct MapButtonMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .labelStyle(.iconOnly)
            .foregroundStyle(.black)
            .font(.system(size: 24))
            .tint(.clear)
            .frame(width: 40, height: 40)
            .clipShape(.circle)
    }
}

struct HintMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12))
    }
}

extension View{
    
    func mapButton() -> some View {
        modifier(MapButtonMod())
    }
    
    func hint() -> some View {
        modifier(HintMod())
    }
    
}


