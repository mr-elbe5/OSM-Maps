/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import CoreLocation
import OSLog

class RouteControlView : UIView{
    
    var controlPanel = UIView()
    var pointPanel = UIView()
    var routeTypeSelector = UISegmentedControl()
    var markerButtons: [UIButton] = []
    let addPointButton = UIButton().asIconButton("plus.circle")
    let removePointButton = UIButton().asIconButton("minus.circle")
    
    let cancelRouteButton = UIButton().asIconButton("xmark", color: .darkText)
    let saveRouteButton = UIButton().asTextButton("save".localize(), color: .systemBlue)
    
    var statusScrollView = UIScrollView()
    var statusPanel = UIView()
    var routepointLines = [RoutepointLine]()
    
    let insets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    func setup(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        backgroundColor = .secondarySystemBackground
        addSubviewBelow(controlPanel, insets: .zero)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "car"), at: 0, animated: false)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "bicycle"), at: 1, animated: false)
        routeTypeSelector.insertSegment(with: UIImage(systemName: "figure.walk"), at: 2, animated: false)
        routeTypeSelector.selectedSegmentIndex = 0
        routeTypeSelector.addTarget(self, action: #selector(routeTypeChanged), for: .valueChanged)
        controlPanel.addSubviewToRight(routeTypeSelector, insets: OSInsets.smallInsets)
        controlPanel.addSubviewWithAnchors(saveRouteButton, leading: routeTypeSelector.trailingAnchor, insets: .defaultInsets)
            .centerY(routeTypeSelector.centerYAnchor)
        saveRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.prepareRouteForSaving()
        }, for: .touchDown)
        controlPanel.addSubviewWithAnchors(cancelRouteButton, trailing: controlPanel.trailingAnchor, insets: .defaultInsets)
            .centerY(routeTypeSelector.centerYAnchor)
        cancelRouteButton.addAction(UIAction(){ action in
            MainViewController.shared.cancelRoute()
        }, for: .touchDown)
        
        addSubviewWithAnchors(pointPanel, top: controlPanel.bottomAnchor, leading: leadingAnchor, insets: .zero)
        addPointButton.addAction(UIAction(){ action in
            MainViewController.shared.addRoutePoint()
        }, for: .touchDown)
        addSubviewWithAnchors(addPointButton, top: controlPanel.bottomAnchor, leading: pointPanel.trailingAnchor, insets: insets)
        removePointButton.addAction(UIAction(){ action in
            MainViewController.shared.removeRoutePoint()
        }, for: .touchDown)
        addSubviewWithAnchors(removePointButton, top: controlPanel.bottomAnchor, leading: addPointButton.trailingAnchor, trailing: trailingAnchor, insets: insets)
        statusScrollView.backgroundColor = .tertiarySystemBackground
        statusScrollView.scrollsToTop = false
        addSubviewBelow(statusScrollView, upperView: pointPanel, insets: .zero)
            .height(200)
            .connectToBottom(of: self)
        statusScrollView.addSubviewWithAnchors(statusPanel, top: statusScrollView.topAnchor, leading: statusScrollView.leadingAnchor, bottom: statusScrollView.bottomAnchor, insets: .zero)
            .width(statusScrollView.widthAnchor, inset: 0)
        update()
    }
    
    func update(){
        updateButtons()
        updateState()
        updateStatusPanel()
        isHidden = VisibleRoute.shared.routeItem == nil
    }
    
    func updateButtons(){
        pointPanel.removeAllSubviews()
        markerButtons.removeAll()
        if let route = VisibleRoute.shared.route {
            var lastView: UIView? = nil
            if route.isEditable{
                for i in 0..<route.navigationPoints.count {
                    var col = ""
                    switch i {
                    case 0:
                        col = "marker-green"
                    case route.navigationPoints.count-1:
                        col = "marker-red"
                    default:
                        col = "marker-yellow"
                    }
                    let button = UIButton().asImageButton(col)
                    pointPanel.addSubviewToRight(button, leftView: lastView, insets: insets)
                    button.addAction(UIAction(){ action in
                        MainViewController.shared.markerButtonPressed(i)
                    }, for: .touchDown)
                    markerButtons.append(button)
                    lastView = button
                }
            }
        }
    }
    
    func updateState(){
        if let route = VisibleRoute.shared.route, route.isEditable{
            pointPanel.isHidden = false
            for idx in 0..<markerButtons.count{
                let btn = markerButtons[idx]
                if idx == VisibleRoute.shared.selectedIndex{
                    btn.setRoundedBorders()
                }
                else{
                    btn.unsetRoundedBorders()
                }
            }
            routeTypeSelector.isEnabled = true
            saveRouteButton.isHidden = !route.isComplete
            addPointButton.isHidden = false
            removePointButton.isHidden = false
            addPointButton.isEnabled = route.navigationPoints.count < VisibleRoute.MAX_NAVIGATION_POINTS
            removePointButton.isEnabled = route.navigationPoints.count > 2
        }
        else{
            routeTypeSelector.isEnabled = false
            saveRouteButton.isHidden = true
            pointPanel.isHidden = true
            addPointButton.isHidden = true
            removePointButton.isHidden = true
        }
    }
    
    func updateStatusPanel(){
        statusPanel.removeAllSubviews()
        routepointLines.removeAll()
        if let route = VisibleRoute.shared.route {
            var linePanel = newLine(iconName: "arrow.right", text: "\(route.distance)m")
            statusPanel.addSubviewBelow(linePanel, insets: .zero)
            var lastLine = linePanel
            linePanel = newLine(iconName: "stopwatch", text: route.duration.hmsString())
            statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
            lastLine = linePanel
            let str = "routeType_" + route.type.rawValue
            linePanel = newLine(text: "\("routeType".localize()): \(str.localize())")
            statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
            lastLine = linePanel
            var lastDistance = 0
            var routepointLine: RoutepointLine!
            for i in 0..<route.routepoints.count {
                let routepoint = route.routepoints[i]
                if lastDistance > 0 {
                    linePanel = newLine(text: "\("after".localize()) \(lastDistance)m:")
                    statusPanel.addSubviewBelow(linePanel, upperView: lastLine, insets: .zero)
                    lastLine = linePanel
                }
                lastDistance = routepoint.distance
                let iconName: String = routepoint.iconName
                var str = routepoint.directionString
                if !routepoint.name.isEmpty {
                    str += "\("on".localize()) \(routepoint.name)"
                }
                routepointLine = RoutepointLine(idx: i)
                if iconName.isEmpty {
                    routepointLine.setupView(text: str)
                }
                else{
                    routepointLine.setupView(iconName: iconName, text: str)
                }
                statusPanel.addSubviewBelow(routepointLine, upperView: lastLine, insets: .zero)
                lastLine = routepointLine
                routepointLines.append(routepointLine)
            }
            lastLine.connectToBottom(of: statusPanel)
        }
    }
    
    func newLine(iconName: String, text: String) -> UIView {
        let linePanel = UIView()
        let icon = UIImageView(image: UIImage(systemName: iconName))
        icon.tintColor = .darkText
        linePanel.addSubviewToRight(icon, insets: OSInsets.smallInsets)
        let label = UILabel()
        label.text = text
        linePanel.addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
        return linePanel
    }
    
    func newLine(text: String) -> UIView {
        let linePanel = UIView()
        let label = UILabel()
        label.text = text
        linePanel.addSubviewToRight(label, insets: OSInsets.smallInsets)
        return linePanel
    }
    
    @objc func routeTypeChanged(){
        let idx = self.routeTypeSelector.selectedSegmentIndex
        Logger.info(" idx \(idx)")
        let type = RouteType.getRouteType(idx: idx)
        Logger.info(" type \(type.rawValue)")
        MainViewController.shared.setRouteType(type)
    }
    
    class RoutepointLine : UIView {
        
        let idx: Int
        
        let label = UILabel()
        
        init(idx: Int) {
            self.idx = idx
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupView(text: String) {
            label.text = text
            addSubviewFilling(label, insets: OSInsets.smallInsets)
        }
        
        func setupView(iconName: String, text: String) {
            let icon = UIImageView(image: UIImage(systemName: iconName))
            icon.tintColor = .darkText
            addSubviewToRight(icon, insets: OSInsets.smallInsets)
            label.text = text
            addSubviewToRight(label, leftView: icon, insets: OSInsets.smallInsets)
        }
        
        func activate(_ flag: Bool){
            label.font = flag ? UIFont.boldSystemFont(ofSize: label.font.pointSize) : UIFont.systemFont(ofSize: label.font.pointSize)
        }
        
    }
}


