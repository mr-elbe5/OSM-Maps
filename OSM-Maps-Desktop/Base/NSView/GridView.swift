/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

import UniformTypeIdentifiers

class GridView: NSView, GridMenuDelegate{
    
    static var defaultGridSize: CGFloat = 200
    static var gridSizeFactors : Array<CGFloat> = [0.5, 0.75, 1.0, 1.5, 2.0]
    
    var items = Array<MapItem>()
    var idx: Int = 0
    let scrollView = NSScrollView()
    let collectionView = NSCollectionView()
    let layout = NSCollectionViewGridLayout()
    
    var delegate: GridMenuDelegate?
    
    init(idx: Int){
        self.idx = idx
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        items.deselectAll()
    }
    
    override func setupView() {
        super.setupView()
        backgroundColor = .black
    }
    
    func updateView(){
        collectionView.removeAllSubviews()
        updateData()
    }
    
    func updateData(){
    }
    
    func increasePreviewSize() {
        if Preferences.shared.gridSizeFactorIndex < TrackGridView.gridSizeFactors.count - 1{
            Preferences.shared.gridSizeFactorIndex += 1
            setCellSize()
        }
    }
    
    func decreasePreviewSize() {
        if Preferences.shared.gridSizeFactorIndex > 0{
            Preferences.shared.gridSizeFactorIndex -= 1
            setCellSize()
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
        setCellSize()
        collectionView.collectionViewLayout = layout
        
    }
    
    func setCellSize(){
        let gridSize = GridView.defaultGridSize * GridView.gridSizeFactors[Preferences.shared.gridSizeFactorIndex]
        layout.minimumItemSize = CGSize(width: gridSize * 0.75, height: gridSize * 0.75)
        layout.maximumItemSize = CGSize(width: gridSize * 1.25, height: gridSize * 1.25)
    }
    
    func selectAll() {
        items.selectAll()
        collectionView.reloadData()
    }
    
    func deselectAll() {
        items.deselectAll()
        collectionView.reloadData()
    }
    
    func deleteSelected() {
        let selected = getSelectedItems()
        if !selected.isEmpty{
            if NSAlert.acceptWarning(message: "deleteItemsWarning".localize()){
                AppData.shared.deleteItems(selected)
                for item in selected{
                    items.remove(obj: item)
                }
                collectionView.reloadData()
            }
        }
    }
    
    func getSelectedItems() -> MapItemList{
        var arr = MapItemList()
        for path in collectionView.selectionIndexPaths{
            arr.append(items[path.item])
        }
        arr.sortByDate(ascending: true)
        return arr
    }
    
}

extension GridView: NSCollectionViewDataSource{
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        NSCollectionViewItem()
    }
    
}

extension GridView: NSCollectionViewDelegate{
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? GridItem{
                item.select(true)
                print("selected \(item.item)")
                item.setHighlightState()
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        for indexPath in indexPaths{
            if let item = collectionView.item(at: indexPath) as? GridItem{
                item.select(false)
                print("deselected \(item.item)")
                item.setHighlightState()
            }
        }
    }
    
}

