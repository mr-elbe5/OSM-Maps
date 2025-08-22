/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class IconHelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "iconHelp".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var header = HelpText(headerKey: "topMenu")
        contentView.addSubviewBelow(header)
        var lastView: UIView = header
        var iconText = HelpText(icon: "note.text", key: "notesList")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "photo", key: "imagesList")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "figure.walk", key: "tracksList")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "gearshape", key: "settings")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "questionmark.diamond", key: "thisHelp")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "questionmark.text.page", key: "helpText")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        
        header = HelpText(headerKey: "map")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        iconText = HelpText(icon: "ellipsis", key: "gpsStrength", iconColor: .blue)
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_place", key: "noteMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_photo", key: "imageMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_track", key: "trackMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_places", key: "noteGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_photos", key: "imageGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_tracks", key: "trackGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "marker_mixed", key: "mixedGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        header = HelpText(headerKey: "tracking")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        iconText = HelpText(icon: "figure.walk.departure", key: "startTrackIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "pause.circle", key: "pauseIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "stop.circle", key: "stopIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "safari", key: "compassIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "mountain.2.circle", key: "mountainIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "arrow.right", key: "arrowRightIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "arrow.up", key: "arrowUpIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "arrow.down", key: "arrowDownIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "stopwatch", key: "clockIcon")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        lastView.connectToBottom(of: contentView)
        
    }
    
}
