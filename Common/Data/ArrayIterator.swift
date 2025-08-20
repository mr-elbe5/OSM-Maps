/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct ArrayIterator<T: Any>: IteratorProtocol {
    
    let array: Array<T>
    var idx = 0

    init(_ array: Array<T>) {
        self.array = array
    }

    mutating func next() -> T? {
        guard array.count > idx else { return nil }
        idx += 1
        return array[idx - 1]
    }
}
