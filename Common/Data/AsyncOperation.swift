/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

class AsyncOperation : Operation, @unchecked Sendable{
    
    enum State: String {
        case isReady
        case isExecuting
        case isFinished
    }
    
    var state: State = .isReady {
        willSet(newValue) {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isExecuting: Bool { state == .isExecuting }
    
    override var isFinished: Bool {
        if isCancelled && state != .isExecuting { return true }
        return state == .isFinished
    }
    
    override var isAsynchronous: Bool { true }
    
    override func start() {
        guard !isCancelled else { return }
        state = .isExecuting
        startExecution()
    }
    
    func startExecution(){
        // override this
    }
    
}
