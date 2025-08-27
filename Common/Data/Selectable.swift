/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

protocol Selectable: AnyObject{
    
    var selected: Bool  { get set }
    
}

typealias SelectableList<T: Selectable> = Array<T>

extension SelectableList{
    
    var allSelected: Bool{
        get{
            allSatisfy({
                $0.selected
            })
        }
    }
    
    var allUnselected: Bool{
        get{
            allSatisfy({
                !$0.selected
            })
        }
    }
    
    var anySelected: Bool{
        get{
            !allUnselected
        }
    }
    
    mutating func selectAll(){
        for item in self{
            item.selected = true
        }
    }
    
    mutating func deselectAll(){
        for item in self{
            item.selected = false
        }
    }
    
    mutating func toggleSelection(){
        var selected = false
        for item in self{
            if item.selected{
                selected = true
                break
            }
        }
        for item in self{
            item.selected = !selected
        }
    }
    
}



