/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class HelpViewController: ScrollViewController{
    
    
    override func loadView() {
        title = "help".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var header = HelpText(headerKey: "helpGeneral")
        contentView.addSubviewBelow(header)
        var lastView: UIView = header
        let text = HelpText(key: "helpGeneralText")
        contentView.addSubviewBelow(text, upperView: lastView)
        lastView = text
        
        header = HelpText(headerKey: "mainMenu")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        var iconText = HelpText(icon: "note.text", key: "notesList", moreAction: UIAction(){ action in
            let controller = NoteHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "photo", key: "imagesList", moreAction: UIAction(){ action in
            let controller = ImageHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "video.badge.waveform", key: "avMediaList", moreAction: UIAction(){ action in
            let controller = AVMediaHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "figure.walk", key: "tracksList", moreAction: UIAction(){ action in
            let controller = TrackHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", key: "routesList", moreAction: UIAction(){ action in
            let controller = RouteHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "gearshape", key: "settings", moreAction: UIAction(){ action in
            let controller = SettingsHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "questionmark.circle", key: "thisHelp")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        header = HelpText(headerKey: "map")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        iconText = HelpText(icon: "ellipsis", key: "gpsStrength", iconColor: .blue)
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.green", key: "noteMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.red", key: "imageMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.blue", key: "trackMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.group.green", key: "noteGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.group.red", key: "imageGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.group.blue", key: "trackGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(image: "mappin.group.purple", key: "mixedGroupMarker")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        let linkButton = UIButton(name: "more".localize(table: "Help"), action: UIAction(){ action in
            let controller = MapHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(linkButton, upperView: lastView)
        lastView = linkButton
        
        header = HelpText(headerKey: "topMenu")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        
        iconText = HelpText(icon: "plus.circle", key: "centerCross", iconColor: .darkColor)
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "record.circle", key: "centerIcon", iconColor: .darkColor)
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "magnifyingglass", key: "searchIcon", iconColor: .darkColor)
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        header = HelpText(headerKey: "leftMenu")
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
        iconText = HelpText(icon: "camera", key: "openCamera")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "microphone", key: "openAudio")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "point.topright.arrow.triangle.backward.to.point.bottomleft.scurvepath", key: "createRoute", moreAction: UIAction(){ action in
            let controller = CreateRouteHelpViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        })
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        header = HelpText(headerKey: "rightMenu")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        iconText = HelpText(icon: "plus", key: "zoomIn")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "minus", key: "zoomOut")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        iconText = HelpText(icon: "arrow.clockwise", key: "refresh")
        contentView.addSubviewBelow(iconText, upperView: lastView)
        lastView = iconText
        
        header = HelpText(headerKey: "bottomStatus")
        contentView.addSubviewBelow(header, upperView: lastView)
        lastView = header
        
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
