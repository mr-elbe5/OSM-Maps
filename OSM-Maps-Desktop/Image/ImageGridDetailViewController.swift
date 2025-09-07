/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation

class ImageGridDetailViewController: PopoverViewController {
    
    var image: ImageItem
    
    let stackView = NSStackView()
    
    init(image: ImageItem){
        self.image = image
        super.init()
        popover.behavior = .transient
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubviewFilling(stackView, insets: .smallInsets)
        image.loadMetaData()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = OSInsets.smallInset
        let nameView = NSTextField(labelWithString: image.url.lastPathComponent)
        let lensModelView = NSTextField(labelWithString: image.metaData?.cameraModel ?? "")
        let widthView = NSTextField(labelWithString: intString(val: image.metaData?.width) + " px")
        let heightView = NSTextField(labelWithString: intString(val: image.metaData?.height) + " px")
        let coordinateView = NSTextField(labelWithString: coordString(lat: image.metaData?.latitude, lon: image.metaData?.longitude))
        let altitudeView = NSTextField(labelWithString: altString(val: image.metaData?.altitude))
        let exifCreationDateView = NSTextField(labelWithString: image.metaData?.dateTime?.dateTimeString() ?? "")
        addDataLine(name: "name".localize(), view: nameView)
        addDataLine(name: "camera".localize(), view: lensModelView)
        addDataLine(name: "width".localize(), view: widthView)
        addDataLine(name: "height".localize(), view: heightView)
        addDataLine(name: "coordinates".localize(), view: coordinateView)
        addDataLine(name: "altitude".localize(), view: altitudeView)
        addDataLine(name: "creationDate".localize(), view: exifCreationDateView)
    }
        
    func intString(val: Double?) -> String{
        if let val = val{
            return String(Int(val))
        }
        return ""
    }
    
    func altString(val: Double?) -> String{
        if let val = val{
            return String(Int(val)) + " m"
        }
        return ""
    }
    
    func coordString(lat: Double?, lon: Double?) -> String{
        if let lat = lat, let lon = lon{
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return coord.asShortString
        }
        return ""
    }
    
    func addDataLine(name: String, view: NSView){
        let line = NSView()
        let label = NSTextField(labelWithString: name.localize() + ": ")
        label.textColor = .white
        line.addSubview(label)
        label.setAnchors(top: line.topAnchor, leading: line.leadingAnchor, bottom: line.bottomAnchor)
        line.addSubview(view)
        view.setAnchors(top: line.topAnchor, leading: label.trailingAnchor, trailing: line.trailingAnchor, bottom: line.bottomAnchor)
        stackView.addArrangedSubview(line)
    }
    
}

