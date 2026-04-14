/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import CloudKit

class ICloudViewController: PopoverViewController {
    
    var contentView: ICloudView{
        view as! ICloudView
    }
    
    override func loadView() {
        view = ICloudView(controller: self)
        view.frame = CGRect(origin: .zero, size: CGSize(width: 350, height: 0))
        view.setupView()
    }
    
    func showICloudStatus(){
        let synchronizer = CloudSynchronizer()
        Task{
            do{
                AppData.shared.resetDeletedIds()
                if let status = try await synchronizer.getSyncStatus(){
                    DispatchQueue.main.async{
                        self.showInfo(text: status.text)
                    }
                }
            }
            catch{
                DispatchQueue.main.async{
                    self.showError(text: "connectionError".localize())
                }
            }
        }
    }
    
    func synchronizeFromICloud(deleteMissing: Bool){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        Task{
            do{
                AppData.shared.resetDeletedIds()
                try await synchronizer.synchronizeFromICloud(deleteMissing: deleteMissing)
            }
            catch{
                DispatchQueue.main.async{
                    self.showError(text: "synchronizeError".localize())
                }
            }
        }
    }
    
    func synchronizeToICloud(deleteMissing: Bool){
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        Task{
            do{
                try await synchronizer.synchronizeToICloud(deleteMissing: deleteMissing)
            }
            catch{
                DispatchQueue.main.async{
                    self.showError(text: "synchronizeError".localize())
                }
            }
        }
    }
    
    func deleteAllFromICloud() {
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = contentView
        Task{
            do{
                try await synchronizer.deleteAllFromICloud()
            }
            catch{
                DispatchQueue.main.async{
                    self.showError(text: "synchronizeError".localize())
                }
            }
        }
    }
    
    func setSynchronizationSteps(_ value: Int) {
        contentView.setSynchronizationSteps(value)
    }
    
    func nextSynchronizationStep() {
        contentView.nextSynchronizationStep()
    }
    
    func synchronizationDone() {
        DispatchQueue.main.async{
            self.showSuccess(title: "success".localize(), text: "synchronized".localize())
            MainViewController.shared.itemsChanged()
        }
    }
    
    func clearDone() {
        DispatchQueue.main.async{
            DispatchQueue.main.async{
                self.showSuccess(title: "success".localize(), text: "cloudCleared".localize())
                MainViewController.shared.itemsChanged()
            }
        }
    }
    
}

class ICloudView: PopoverView, CloudSynchronizerDelegate {
    
    var showCloudStatusButton = NSButton()
    var synchronizeFromICloudButton = NSButton()
    var synchronizeFromICloudWithDeletionButton = NSButton()
    var synchronizeToICloudButton = NSButton()
    var synchronizeToICloudWithDeletionButton = NSButton()
    var clearICloudButton = NSButton()
    
    var progressView = NSProgressIndicator()
    var currentSyncStep: Int = 0
    var maxSyncSteps: Int = 1
    
    var contentController: ICloudViewController{
        controller as! ICloudViewController
    }
    
    override func setupView() {
        
        var label = NSTextField(wrappingLabelWithString: "synchronizeHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label)
        
        showCloudStatusButton.asTextButton("showSyncStatus".localize(), target: self, action: #selector(showICloudStatus))
        addSubviewCenteredBelow(showCloudStatusButton, upperView: label, insets: OSInsets.doubleInsets)
        label = NSTextField(wrappingLabelWithString: "cloudStatusHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: showCloudStatusButton)
        
        synchronizeFromICloudButton.asTextButton("synchronizeFromCloud".localize(), target: self, action: #selector(synchronizeFromICloud))
        addSubviewCenteredBelow(synchronizeFromICloudButton, upperView: label, insets: OSInsets.doubleInsets)
        label = NSTextField(wrappingLabelWithString: "synchronizeFromCloudHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeFromICloudButton)
        
        synchronizeFromICloudWithDeletionButton.asTextButton("synchronizeFromCloudWithDeletion".localize(), target: self, action: #selector(synchronizeFromICloudWithDeletion))
        addSubviewCenteredBelow(synchronizeFromICloudWithDeletionButton, upperView: label, insets: OSInsets.doubleInsets)
        label = NSTextField(wrappingLabelWithString: "synchronizeFromCloudWithDeletionHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeFromICloudWithDeletionButton)
        
        synchronizeToICloudButton.asTextButton("synchronizeToCloud".localize(), target: self, action: #selector(synchronizeToICloud))
        addSubviewCenteredBelow(synchronizeToICloudButton, upperView: label)
        label = NSTextField(wrappingLabelWithString: "synchronizeToCloudHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeToICloudButton)
        
        synchronizeToICloudWithDeletionButton.asTextButton("synchronizeToCloudWithDeletion".localize(), target: self, action: #selector(synchronizeToICloudWithDeletion))
        addSubviewCenteredBelow(synchronizeToICloudWithDeletionButton, upperView: label)
        label = NSTextField(wrappingLabelWithString: "synchronizeToCloudWithDeletionHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeToICloudWithDeletionButton)
        
        clearICloudButton.asTextButton("clearCloud".localize(), target: self, action: #selector(clearICloud))
        addSubviewCenteredBelow(clearICloudButton, upperView: label)
        label = NSTextField(wrappingLabelWithString: "clearCloudHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: clearICloudButton)
        
        progressView.isIndeterminate = false
        addSubviewBelow(progressView, upperView: label)
            .connectToBottom(of: self)
        
        updateButtonStates()
    }
    
    func setupProgressView(max: Int){
        maxSyncSteps = max
        currentSyncStep = 0
        progressView.minValue = 0
        progressView.maxValue = 1
        progressView.doubleValue = 0
    }
    
    @objc func showICloudStatus(){
        contentController.showICloudStatus()
    }
    
    @objc func synchronizeFromICloud(){
        contentController.synchronizeFromICloud(deleteMissing: false)
    }
    
    @objc func synchronizeFromICloudWithDeletion(){
        contentController.synchronizeFromICloud(deleteMissing: true)
    }
    
    @objc func synchronizeToICloud(){
        contentController.synchronizeToICloud(deleteMissing: false)
    }
    
    @objc func synchronizeToICloudWithDeletion(){
        contentController.synchronizeToICloud(deleteMissing: true)
    }
    
    @objc func clearICloud(){
        (controller as! ICloudViewController).deleteAllFromICloud()
        
    }
    
    func synchronizationDone() {
        (controller as! ICloudViewController).synchronizationDone()
    }
    
    func clearDone() {
        (controller as! ICloudViewController).clearDone()
    }
    
    func updateButtonStates(){
        Task{
            let isOn = try await CKContainer.isConnected()
            synchronizeFromICloudButton.isEnabled = isOn
            synchronizeToICloudButton.isEnabled = isOn
        }
    }
    
    func setSynchronizationSteps(_ value: Int) {
        DispatchQueue.main.async {
            self.setupProgressView(max: value)
        }
    }
    
    func nextSynchronizationStep() {
        DispatchQueue.main.async {
            self.currentSyncStep += 1
            self.progressView.doubleValue = Double(self.currentSyncStep) / Double(self.maxSyncSteps)
        }
    }
    
}

