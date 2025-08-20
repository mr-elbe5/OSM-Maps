/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation
import SwiftUI
import CoreLocation

struct HideMod: ViewModifier {
    
    var hidden: Bool
    
    init(hidden: Bool) {
        self.hidden = hidden
    }
    
    func body(content: Content) -> some View {
        if hidden {
            content.hidden()
        }
        else {
            content
        }
    }
}

struct RoundedRectShapeMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .clipShape(.rect(cornerSize: CGSize(width: 10, height: 10)))
    }
}

struct IconMenuMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background(Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.7))
            .roundedRect()
    }
}

struct CellIconMenuMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(5)
            .background(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2))
            .roundedRect()
    }
}

struct VMenuIconImageMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 18))
            .frame(width: 20, height: 20)
    }
}

struct HMenuIconImageMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 18))
            .frame(width: 20, height: 20)
    }
}

struct MapIconImageMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: 16))
            .foregroundColor(Color.init(red: 0.2, green: 0.2, blue: 0.2))
    }
}

struct HintMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12))
    }
}

struct OffsetMod: ViewModifier {
    
    var offset: CGPoint
    
    init(offset: CGPoint){
        self.offset = offset
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset.x, y: offset.y)
    }
}

struct RedButtonMod: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(RedButton())
    }
}

struct RedButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.red)
    }
}

extension View{
    
    func frame(size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }
    
    func hide(_ hidden: Bool) -> some View {
        modifier(HideMod(hidden: hidden))
    }
    
    func show(_ show: Bool) -> some View {
        hide(!show)
    }
    
    func iconMenu() -> some View {
        modifier(IconMenuMod())
    }
    
    func roundedRect() -> some View {
        modifier(RoundedRectShapeMod())
    }
    
    func cellIconMenu() -> some View {
        modifier(CellIconMenuMod())
    }
    
    func vMenuIconImage() -> some View {
        modifier(VMenuIconImageMod())
    }
    
    func hMenuIconImage() -> some View {
        modifier(HMenuIconImageMod())
    }
    
    func mapIconImage() -> some View {
        modifier(MapIconImageMod())
    }
    
    func offset(_ offset: CGPoint) -> some View {
        modifier(OffsetMod(offset: offset))
    }
    
    func redButton() -> some View {
        modifier(RedButtonMod())
    }
    
    func stackedButton() -> some View {
        buttonStyle(BorderlessButtonStyle())
    }
    
    func hint() -> some View {
        modifier(HintMod())
    }
    
}


