/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class ImagePresenterView: PresenterView {
    
    var items = ImageItemList()
    
    var imageView = NSImageView()
    
    override var itemCount: Int{
        items.count
    }
    
    override func setupItemView(){
        imageView.autoresizingMask = [.height, .width]
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubviewFilling(imageView)
        
    
    }
    
    func setImages(_ items: ImageItemList){
        self.items = items
        setImageView(item: items.first)
        currentIdx = 0
        checkButtons()
    }
    
    func setImage(item: ImageItem){
        var arr = ImageItemList()
        arr.append(item)
        setImages(arr)
        checkButtons()
    }
    
    func setImageView(item: ImageItem?){
        imageView.image = nil
        imageView.isHidden = true
        if let item = item, let img = item.image{
            imageView.isHidden = false
            imageView.image = img
        }
    }
    
    override func setCurrentItem(){
        setImageView(item: items[currentIdx])
    }
    
}




