/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import Foundation

struct BasePaths {
    
    static var tileDirURL = URL.documentsDirectory.appendingPathComponent("tiles")
    static var statusDirURL = URL.applicationSupportDirectory.appendingPathComponent("status")
    static var imageDirURL = URL.documentsDirectory.appendingPathComponent("images")
    static var audioDirURL = URL.documentsDirectory.appendingPathComponent("audios")
    static var videoDirURL = URL.documentsDirectory.appendingPathComponent("videos")
    static var previewDirURL = URL.cachesDirectory.appendingPathComponent("previews")
    static var videoPreviewDirURL = URL.cachesDirectory.appendingPathComponent("videoPreviews")
    
    static func initializeDirs() {
        try! FileManager.default.createDirectory(at: URL.applicationSupportDirectory, withIntermediateDirectories: true, attributes: nil)
        Log.debug("base dir is: \(URL.applicationSupportDirectory.path)")
        Log.debug("document dir is: \(URL.documentsDirectory.path)")
        Log.debug("cache dir is: \(URL.cachesDirectory.path)")
        try! FileManager.default.createDirectory(at: statusDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("status dir is: \(statusDirURL.path)")
        try! FileManager.default.createDirectory(at: tileDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("tile dir is: \(tileDirURL.path)")
        try! FileManager.default.createDirectory(at: imageDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("image dir is: \(imageDirURL.path)")
        try! FileManager.default.createDirectory(at: audioDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("audio dir is: \(audioDirURL.path)")
        try! FileManager.default.createDirectory(at: videoDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("video dir is: \(videoDirURL.path)")
        try! FileManager.default.createDirectory(at: previewDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("preview dir is: \(previewDirURL.path)")
        try! FileManager.default.createDirectory(at: videoPreviewDirURL, withIntermediateDirectories: true, attributes: nil)
        //Log.debug("video preview dir is: \(videoPreviewDirURL.path)")
    }
    
    static func assertNewFileLocations(){
        Log.info("asserting new file locations")
        let oldTileDirURL = URL.applicationSupportDirectory.appendingPathComponent("tiles")
        if FileManager.default.fileExists(atPath: oldTileDirURL.path) {
            let urls = FileManager.default.listAllURLs(dirURL: oldTileDirURL)
            var count = 0
            for url in urls {
                let newURL = tileDirURL.appendingPathComponent(url.lastPathComponent)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try? FileManager.default.moveItem(at: url, to: newURL)
                }
                else{
                    Log.info("file already exists at new path: \(newURL.path)")
                }
                count += 1
            }
            Log.info("moved \(count) tiles to new location: \(tileDirURL.path)")
            try? FileManager.default.removeItem(at: oldTileDirURL)
        }
        let oldImageDirURL = URL.applicationSupportDirectory.appendingPathComponent("images")
        if FileManager.default.fileExists(atPath: oldImageDirURL.path) {
            let urls = FileManager.default.listAllURLs(dirURL: oldImageDirURL)
            var count = 0
            for url in urls {
                let newURL = imageDirURL.appendingPathComponent(url.lastPathComponent)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try? FileManager.default.moveItem(at: url, to: newURL)
                }
                else{
                    Log.info("file already exists at new path: \(newURL.path)")
                }
                count += 1
            }
            Log.info("moved \(count) images to new location: \(imageDirURL.path)")
            try? FileManager.default.removeItem(at: oldImageDirURL)
        }
        let oldAudioDirURL = URL.applicationSupportDirectory.appendingPathComponent("audios")
        if FileManager.default.fileExists(atPath: oldAudioDirURL.path) {
            let urls = FileManager.default.listAllURLs(dirURL: oldAudioDirURL)
            var count = 0
            for url in urls {
                let newURL = audioDirURL.appendingPathComponent(url.lastPathComponent)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try? FileManager.default.moveItem(at: url, to: newURL)
                }
                else{
                    Log.info("file already exists at new path: \(newURL.path)")
                }
                count += 1
            }
            Log.info("moved \(count) audios to new location: \(audioDirURL.path)")
            try? FileManager.default.removeItem(at: oldAudioDirURL)
        }
        let oldVideoDirURL = URL.applicationSupportDirectory.appendingPathComponent("videos")
        if FileManager.default.fileExists(atPath: oldVideoDirURL.path) {
            let urls = FileManager.default.listAllURLs(dirURL: oldVideoDirURL)
            var count = 0
            for url in urls {
                let newURL = videoDirURL.appendingPathComponent(url.lastPathComponent)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try? FileManager.default.moveItem(at: url, to: newURL)
                }
                else{
                    Log.info("file already exists at new path: \(newURL.path)")
                }
                count += 1
            }
            Log.info("moved \(count) videos to new location: \(videoDirURL.path)")
            try? FileManager.default.removeItem(at: oldVideoDirURL)
        }
        let oldPreviewsDirURL = URL.applicationSupportDirectory.appendingPathComponent("previews")
        if FileManager.default.fileExists(atPath: oldPreviewsDirURL.path) {
            let urls = FileManager.default.listAllURLs(dirURL: oldPreviewsDirURL)
            var count = 0
            for url in urls {
                let newURL = previewDirURL.appendingPathComponent(url.lastPathComponent)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try? FileManager.default.moveItem(at: url, to: newURL)
                }
                else{
                    Log.info("file already exists at new path: \(newURL.path)")
                }
                count += 1
            }
            Log.info("moved \(count) previews to new location: \(previewDirURL.path)")
            try? FileManager.default.removeItem(at: oldPreviewsDirURL)
        }
        let oldVideoPreviewsDirURL = URL.applicationSupportDirectory.appendingPathComponent("videoPreviews")
        if FileManager.default.fileExists(atPath: oldVideoPreviewsDirURL.path) {
            let urls = FileManager.default.listAllURLs(dirURL: oldVideoPreviewsDirURL)
            var count = 0
            for url in urls {
                let newURL = videoPreviewDirURL.appendingPathComponent(url.lastPathComponent)
                if !FileManager.default.fileExists(atPath: newURL.path) {
                    try? FileManager.default.moveItem(at: url, to: newURL)
                }
                else{
                    Log.info("file already exists at new path: \(newURL.path)")
                }
                count += 1
            }
            Log.info("moved \(count) previews to new location: \(videoPreviewDirURL.path)")
            try? FileManager.default.removeItem(at: oldVideoPreviewsDirURL)
        }
    }
    
}
