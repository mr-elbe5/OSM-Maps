/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import UniformTypeIdentifiers
import PhotosUI

protocol BackupDelegate{
    func createBackup()
    func restoreBackup()
    func restoreBackupFromMapsForOSM()
}

class BackupViewController: ModalViewController, BackupDelegate {
    
    var contentView = BackupView()
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 0))
        contentView.delegate = self
        view.addSubviewFilling(contentView)
        contentView.setupView()
    }
    
    func createBackup(){
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        savePanel.nameFieldStringValue = "maps4osm_backup_\(Date.localDate.shortFileDate()).zip"
        savePanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        if savePanel.runModal() == .OK{
            let spinner = startSpinner()
            DispatchQueue.main.async {
                if let targetUrl = savePanel.url, Backup.createBackupFile(at: targetUrl){
                    self.showSuccess(title: "success".localize(), text: "backupSaved".localize())
                }
                self.stopSpinner(spinner)
            }
        }
    }
    
    func restoreBackup(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize(table: "Hints")){
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK{
                if let url = openPanel.url{
                    if url.startAccessingSecurityScopedResource(){
                        let spinner = self.startSpinner()
                        DispatchQueue.global(qos: .userInitiated).async {
                            if Backup.unzipBackupFile(zipFileURL: url){
                                if Backup.restoreBackupFile(){
                                    DispatchQueue.main.async {
                                        self.stopSpinner(spinner)
                                        MainViewController.shared.updateItemLayer()
                                        self.showSuccess(title: "success".localize(), text: "restoreDone".localize())
                                    }
                                }
                                else{
                                    DispatchQueue.main.async {
                                        self.stopSpinner(spinner)
                                        self.showError(text: "wrongZipFile".localize())
                                    }
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            }
        }
    }
    
    func restoreBackupFromMapsForOSM(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize(table: "Hints")){
            let openPanel = NSOpenPanel()
            openPanel.allowedContentTypes = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            openPanel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
            openPanel.canChooseFiles = true
            openPanel.canChooseDirectories = false
            openPanel.allowsMultipleSelection = false
            if openPanel.runModal() == .OK{
                if let url = openPanel.url{
                    if url.startAccessingSecurityScopedResource(){
                        let spinner = self.startSpinner()
                        DispatchQueue.global(qos: .userInitiated).async {
                            if Backup.unzipBackupFile(zipFileURL: url){
                                if Backup.importfromMapsForOSMFile(){
                                    DispatchQueue.main.async {
                                        self.stopSpinner(spinner)
                                        MainViewController.shared.updateItemLayer()
                                        self.showSuccess(title: "success".localize(), text: "restoreDone".localize())
                                    }
                                }
                                else{
                                    DispatchQueue.main.async {
                                        self.stopSpinner(spinner)
                                        self.showError(text: "wrongZipFile".localize())
                                    }
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            }
        }
    }
    
}

class BackupView: NSView{
    
    var delegate: BackupDelegate? = nil
    
    override func setupView() {
        
        let createBackupButton = NSButton().asTextButton("createBackup".localize(), target: self, action: #selector(createBackup))
        addSubviewCenteredBelow(createBackupButton, insets: OSInsets.doubleInsets)
        
        let restoreBackupButton = NSButton().asTextButton("restoreBackup".localize(), target: self, action: #selector(restoreBackup))
        addSubviewCenteredBelow(restoreBackupButton, upperView: createBackupButton, insets: OSInsets.doubleInsets)
        
        let restoreBackupFromMapsForOSMButton = NSButton().asTextButton("restoreBackup".localize(), target: self, action: #selector(restoreBackupFromMapsForOSM))
        addSubviewCenteredBelow(restoreBackupFromMapsForOSMButton, upperView: restoreBackupButton, insets: OSInsets.doubleInsets)
            .connectToBottom(of: self)
    }
    
    @objc func createBackup(){
        delegate?.createBackup()
    }
    
    @objc func restoreBackup(){
        delegate?.restoreBackup()
    }
    
    @objc func restoreBackupFromMapsForOSM(){
        delegate?.restoreBackupFromMapsForOSM()
    }
    
}

