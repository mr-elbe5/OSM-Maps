/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit

class MainMenuView: NSView{
    
    var centerMenu: NSSegmentedControl!
    var rightMenu = NSView()
    
    var openViewSettingsButton: NSButton!
    var openICloudButton: NSButton!
    var openBackupButton: NSButton!
    var openPreferencesButton: NSButton!
    var openHelpButton: NSButton!
    
    var insets = OSInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    init(){
        super.init(frame: .zero)
        var centerImages = Array<NSImage>()
        centerImages.append(NSImage(systemSymbolName: "map", accessibilityDescription: "map".localize())!)
        centerImages.append(NSImage(systemSymbolName: "photo", accessibilityDescription: "images".localize())!)
        centerImages.append(NSImage(systemSymbolName: "video", accessibilityDescription: "videos".localize())!)
        centerImages.append(NSImage(systemSymbolName: "figure.walk", accessibilityDescription: "tracks".localize())!)
        centerMenu = NSSegmentedControl(images: centerImages, trackingMode: NSSegmentedControl.SwitchTracking.selectOne, target: self, action: #selector(centerMenuChanged))
        centerMenu.setLabel("map".localize(), forSegment: 0)
        centerMenu.setLabel("images".localize(), forSegment: 1)
        centerMenu.setLabel("videos".localize(), forSegment: 2)
        centerMenu.setLabel("tracks".localize(), forSegment: 3)
        centerMenu.selectedSegment = 0
        
        openViewSettingsButton = NSButton(icon: "calendar", target: self, action: #selector(openViewSettings))
        openViewSettingsButton.toolTip = "viewSettings".localize()
        openICloudButton = NSButton(icon: "cloud", target: self, action: #selector(openICloud))
        openICloudButton.toolTip = "iCloud".localize()
        openBackupButton = NSButton(icon: "zipper.page", target: self, action: #selector(openBackup))
        openBackupButton.toolTip = "data".localize()
        openPreferencesButton = NSButton(icon: "gearshape", target: self, action: #selector(openPreferences))
        openPreferencesButton.toolTip = "settings".localize()
        openHelpButton = NSButton(icon: "questionmark", target: self, action: #selector(openHelp))
        openHelpButton.toolTip = "help".localize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupView(){
        backgroundColor = .black
        addSubviewWithAnchors(centerMenu, top: topAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets).centerX(centerXAnchor)
        addSubviewWithAnchors(rightMenu, top: topAnchor, trailing: trailingAnchor, bottom: bottomAnchor, insets: OSInsets.smallInsets)
        rightMenu.addSubviewToRight(openViewSettingsButton, insets: insets)
        rightMenu.addSubviewToRight(openICloudButton, leftView: openViewSettingsButton, insets: insets)
        rightMenu.addSubviewToRight(openBackupButton, leftView: openICloudButton, insets: insets)
        rightMenu.addSubviewToRight(openPreferencesButton, leftView: openBackupButton, insets: insets)
        rightMenu.addSubviewToRight(openHelpButton, leftView: openPreferencesButton, insets: insets)
            .connectToRight(of: rightMenu, inset: .zero)
    }
    
    @objc func centerMenuChanged(){
        switch centerMenu.selectedSegment{
        case 0: MainViewController.shared.setView(.map)
        case 1: MainViewController.shared.setView(.imageGrid)
        case 2: MainViewController.shared.setView(.avGrid)
        case 3: MainViewController.shared.setView(.trackGrid)
        default: return
        }
    }
    
    @objc func openViewSettings(){
        MainViewController.shared.openViewSettings(at: openViewSettingsButton)
    }
    
    @objc func openICloud(){
        MainViewController.shared.openICloud(at: openICloudButton)
    }
    
    @objc func openBackup(){
        MainViewController.shared.openBackup(at: openBackupButton)
    }
    
    @objc func openPreferences(){
        MainViewController.shared.openPreferences(at: openPreferencesButton)
    }
    
    @objc func openHelp(){
        MainViewController.shared.openHelp(at: openHelpButton)
    }
    
}
    
