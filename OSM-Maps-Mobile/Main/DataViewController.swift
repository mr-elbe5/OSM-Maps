/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import UniformTypeIdentifiers

class DataViewController: ScrollViewController{
    
    // cloud
    
    var syncProgressView = UIProgressView()
    var currentSyncStep: Int = 0
    var maxSyncSteps: Int = 1
    
    override func loadView() {
        title = "data".localize()
        super.loadView()
        view.addSubviewFillingSafeArea(scrollView, insets: .zero)
        scrollView.backgroundColor = .systemBackground
        setupScrollView()
        loadScrollableSubviews()
    }
    
    func loadScrollableSubviews() {
        
        var header = UILabel(header: "data".localize())
        contentView.addSubviewBelow(header)
        
        let deleteDataButton = UIButton()
        deleteDataButton.setTitle("deleteAllData".localize(), for: .normal)
        deleteDataButton.setTitleColor(.systemBlue, for: .normal)
        deleteDataButton.addAction(UIAction(){ action in
            self.deleteAllData()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(deleteDataButton, upperView: header)
        
        header = UILabel(header: "iCloud".localize())
        contentView.addSubviewBelow(header, upperView: deleteDataButton)
        
        let syncNowButton = UIButton()
        syncNowButton.setTitle("synchronizeNow".localize(), for: .normal)
        syncNowButton.setTitleColor(.systemBlue, for: .normal)
        syncNowButton.addAction(UIAction(){ action in
            self.synchronizeFull()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(syncNowButton, upperView: header)
        var hint = UILabel(hint: "synchronizeHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: syncNowButton, insets: OSInsets.flatInsets)
        
        let synchronizeFromCloudButton = UIButton()
        synchronizeFromCloudButton.setTitle("synchronizeFromCloud".localize(), for: .normal)
        synchronizeFromCloudButton.setTitleColor(.systemBlue, for: .normal)
        synchronizeFromCloudButton.addAction(UIAction(){ action in
            self.synchronizeFromCloud()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(synchronizeFromCloudButton, upperView: hint)
        hint = UILabel(hint: "synchronizeFromCloudHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: synchronizeFromCloudButton, insets: OSInsets.flatInsets)
        
        let synchronizeToCloudButton = UIButton()
        synchronizeToCloudButton.setTitle("synchronizeToCloud".localize(), for: .normal)
        synchronizeToCloudButton.setTitleColor(.systemBlue, for: .normal)
        synchronizeToCloudButton.addAction(UIAction(){ action in
            self.synchronizeToCloud()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(synchronizeToCloudButton, upperView: hint)
        hint = UILabel(hint: "synchronizeToCloudHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: synchronizeToCloudButton, insets: OSInsets.flatInsets)
        
        let clearCloudButton = UIButton()
        clearCloudButton.setTitle("clearCloud".localize(), for: .normal)
        clearCloudButton.setTitleColor(.systemBlue, for: .normal)
        clearCloudButton.addAction(UIAction(){ action in
            self.clearCloud()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(clearCloudButton, upperView: hint)
        hint = UILabel(hint: "clearCloudHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: clearCloudButton, insets: OSInsets.flatInsets)
        let cloudProgressLabel = UILabel(hint: "progress".localizeWithColon())
        contentView.addSubviewBelow(cloudProgressLabel, upperView: hint)
        setSynchronizationSteps(1)
        contentView.addSubviewBelow(syncProgressView, upperView: cloudProgressLabel)
        
        header = UILabel(header: "backup".localize())
        contentView.addSubviewBelow(header, upperView: syncProgressView)
        
        let createBackupButton = UIButton()
        createBackupButton.setTitle("createBackup".localize(), for: .normal)
        createBackupButton.setTitleColor(.systemBlue, for: .normal)
        createBackupButton.addAction(UIAction(){ action in
            self.createBackup()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(createBackupButton, upperView: header)
        hint = UILabel(hint: "backupHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: createBackupButton, insets: OSInsets.flatInsets)
        
        let restoreBackupButton = UIButton()
        restoreBackupButton.setTitle("restoreBackup".localize(), for: .normal)
        restoreBackupButton.setTitleColor(.systemBlue, for: .normal)
        restoreBackupButton.addAction(UIAction(){ action in
            self.restoreBackup()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(restoreBackupButton, upperView: hint)
        hint = UILabel(hint: "restoreBackupHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: restoreBackupButton, insets: OSInsets.flatInsets)
        
        let restoreFromMapsForOSMButton = UIButton()
        restoreFromMapsForOSMButton.setTitle("restoreFromMapsForOSM".localize(), for: .normal)
        restoreFromMapsForOSMButton.setTitleColor(.systemBlue, for: .normal)
        restoreFromMapsForOSMButton.addAction(UIAction(){ action in
            self.restoreBackupFromMapsForOSM()
        }, for: .touchDown)
        contentView.addSubviewCenteredBelow(restoreFromMapsForOSMButton, upperView: hint)
        hint = UILabel(hint: "restoreFromMapsForOSMHint".localize(table: "Hints"))
        contentView.addSubviewBelow(hint, upperView: restoreFromMapsForOSMButton, insets: OSInsets.flatInsets)
            .connectToBottom(of: contentView)
        
    }
    
}

extension DataViewController{
    
    // cloud
    
    func synchronizeFull(){
        showDestructiveApprove(title: "synchronize".localize(), text: "synchronizeWarnHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer(syncType: .full)
            synchronizer.delegate = self
            Task{
                synchronizer.synchronize()
            }
        }
    }
    
    func synchronizeFromCloud(){
        showDestructiveApprove(title: "synchronizeFromCloud".localize(), text: "synchronizeWarnHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer(syncType: .fromCloud)
            synchronizer.delegate = self
            Task{
                synchronizer.synchronize()
            }
        }
    }
    
    func synchronizeToCloud(){
        showDestructiveApprove(title: "synchronizeToCloud".localize(), text: "synchronizeWarnHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer(syncType: .toCloud)
            synchronizer.delegate = self
            Task{
                synchronizer.synchronize()
            }
        }
    }
    
    func clearCloud(){
        showDestructiveApprove(title: "synchronize".localize(), text: "synchronizeHint".localize(table: "Hints")){
            let synchronizer = CloudSynchronizer()
            synchronizer.delegate = self
            Task{
                synchronizer.clear()
            }
        }
    }
    
    // backup
    
    func createBackup(){
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("osmmaps_backup_\(Date.now.fileNameString).zip")
        let spinner = startSpinner()
        DispatchQueue.global(qos: .userInitiated).async {
            if Backup.createBackupFile(at: url){
                DispatchQueue.main.async {
                    let picker = UIDocumentPickerViewController(forExporting: [url])
                    picker.delegate = nil
                    picker.title = "backup".localize()
                    self.present(picker, animated: true)
                    self.stopSpinner(spinner)
                }
            }
            else{
                DispatchQueue.main.async {
                    self.showError("backupNotCreated".localize())
                    self.stopSpinner(spinner)
                }
            }
        }
        
    }
    
    func deleteAllData(){
        showDestructiveApprove(title: "deleteAllData".localize(), text: "deleteAllDataHint".localize(table: "Hints")){
            AppData.shared.deleteAllData()
        }
    }
    
    func restoreBackup(){
        showDestructiveApprove(title: "restoreBackup".localize(), text: "restoreBackupHint".localize(table: "Hints")){
            let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            picker.title = "restore".localize()
            picker.delegate = self
            let spinner = self.startSpinner()
            self.present(picker, animated: true, completion: nil)
            self.stopSpinner(spinner)
        }
    }
    
    func restoreBackupFromMapsForOSM(){
        showDestructiveApprove(title: "restoreFromMapsForOSM".localize(), text: "restoreBackupHint".localize(table: "Hints")){
            let types = UTType.types(tag: "zip", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
            picker.title = "restoreOld".localize()
            picker.delegate = self
            let spinner = self.startSpinner()
            self.present(picker, animated: true, completion: nil)
            self.stopSpinner(spinner)
        }
    }
    
}

extension DataViewController : CloudSynchronizerDelegate{
    
    func setSynchronizationSteps(_ value: Int) {
        maxSyncSteps = value
        currentSyncStep = 0
        syncProgressView.progress = 0
    }
    
    func nextSynchronizationStep() {
        currentSyncStep += 1
        syncProgressView.setProgress(Float(currentSyncStep) / Float(maxSyncSteps), animated: false)
    }
    
    func synchronizationDone() {
        DispatchQueue.main.async{
            self.showDone(title: "success".localize(), text: "synchronized".localize())
            MainViewController.shared.updateItemLayer()
        }
    }
    
    func clearDone() {
        DispatchQueue.main.async{
            self.showDone(title: "success".localize(), text: "cloudCleared".localize())
        }
    }
    
}

extension DataViewController : UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.title == "restore".localize(){
            if let url = urls.first, url.pathExtension == "zip"{
                if url.startAccessingSecurityScopedResource(){
                    let spinner = startSpinner()
                    DispatchQueue.global(qos: .userInitiated).async {
                        if Backup.unzipBackupFile(zipFileURL: url){
                            if Backup.restoreBackupFile(){
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                                    MainViewController.shared.updateItemLayer()
                                }
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showError("wrongZipFile".localize())
                                }
                            }
                        }
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            }
            return
        }
        if controller.title == "restoreOld".localize(){
            if let url = urls.first, url.pathExtension == "zip"{
                if url.startAccessingSecurityScopedResource(){
                    let spinner = startSpinner()
                    DispatchQueue.global(qos: .userInitiated).async {
                        if Backup.unzipBackupFile(zipFileURL: url){
                            if Backup.importfromMapsForOSMFile(){
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showDone(title: "success".localize(), text: "restoreDone".localize())
                                    MainViewController.shared.updateItemLayer()
                                }
                                
                            }
                            else{
                                DispatchQueue.main.async {
                                    self.stopSpinner(spinner)
                                    self.showError("wrongZipFile".localize())
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



    

