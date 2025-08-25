/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

protocol GridMenuDelegate{
    func increasePreviewSize()
    func decreasePreviewSize()
}

class GridView: NSView, GridMenuDelegate{
    
    static var defaultGridSize: CGFloat = 200
    static var gridSizeFactors : Array<CGFloat> = [0.5, 0.75, 1.0, 1.5, 2.0]
    
    let scrollView = NSScrollView()
    let collectionView = NSCollectionView()
    let layout = NSCollectionViewGridLayout()
    
    var gridSize: CGFloat{
        GridView.defaultGridSize * GridView.gridSizeFactors[Preferences.shared.gridSizeFactorIndex]
    }
    
    func increasePreviewSize() {
        if Preferences.shared.gridSizeFactorIndex < TrackGridView.gridSizeFactors.count - 1{
            Preferences.shared.gridSizeFactorIndex += 1
            let gridSize = gridSize
            layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
            layout.minimumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
        }
    }
    
    func decreasePreviewSize() {
        if Preferences.shared.gridSizeFactorIndex > 0{
            Preferences.shared.gridSizeFactorIndex -= 1
            layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
            layout.minimumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
        }
    }
    
    func setupCollectionView() {
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.isSelectable = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = collectionView
        layout.minimumLineSpacing = OSInsets.smallInset
        layout.minimumInteritemSpacing = OSInsets.smallInset
        let gridSize = gridSize
        layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
        layout.maximumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
        collectionView.collectionViewLayout = layout
        
    }
    
}

