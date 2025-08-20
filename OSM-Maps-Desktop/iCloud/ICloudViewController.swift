/*
 OSM Maps
 Display and use of OSM maps
 Copyright: Michael Rönnau mr@elbe5.de
 */

import AppKit
import CoreLocation
import CloudKit

protocol CloudViewDelegate{
    func synchronizeFromICloud()
    func synchronizeToICloud()
    func synchronizeNow()
    func clearICloud()
}

class ICloudViewController: ModalViewController, CloudViewDelegate {
    
    var contentView = ICloudView()
    
    override func loadView() {
        super.loadView()
        view.frame = CGRect(origin: .zero, size: CGSize(width: 350, height: 0))
        view.addSubviewFilling(contentView)
        contentView.setupView()
        contentView.delegate = self
    }
    
    func synchronizeFromICloud(){
        let synchronizer = CloudSynchronizer(syncType: .fromCloud)
        synchronizer.delegate = self
        Task{
            synchronizer.synchronize()
        }
    }
    
    func synchronizeToICloud(){
        let synchronizer = CloudSynchronizer(syncType: .toCloud)
        synchronizer.delegate = self
        Task{
            synchronizer.synchronize()
        }
    }
    
    func synchronizeNow(){
        let synchronizer = CloudSynchronizer(syncType: .full)
        synchronizer.delegate = self
        Task{
            synchronizer.synchronize()
        }
    }
    
    func clearICloud() {
        let synchronizer = CloudSynchronizer()
        synchronizer.delegate = self
        Task{
            synchronizer.clear()
        }
    }
    
}

extension ICloudViewController : CloudSynchronizerDelegate{
    
    func setSynchronizationSteps(_ value: Int) {
        contentView.setSynchronizationSteps(value)
    }
    
    func nextSynchronizationStep() {
        contentView.nextSynchronizationStep()
    }
    
    func synchronizationDone() {
        DispatchQueue.main.async{
            MainViewController.shared.updateItemLayer()
            DispatchQueue.main.async{
                self.showSuccess(title: "success".localize(), text: "synchronized".localize())
                MainViewController.shared.updateItemLayer()
            }
        }
    }
    
    func clearDone() {
        DispatchQueue.main.async{
            DispatchQueue.main.async{
                self.showSuccess(title: "success".localize(), text: "cloudCleared".localize())
                MainViewController.shared.updateItemLayer()
            }
        }
    }
    
}

class ICloudView: NSView {
    
    var synchronizeFromICloudButton = NSButton()
    var synchronizeToICloudButton = NSButton()
    var synchronizeButton = NSButton()
    var clearICloudButton = NSButton()
    
    var progressView = NSProgressIndicator()
    var currentSyncStep: Int = 0
    var maxSyncSteps: Int = 1
    
    var delegate: CloudViewDelegate? = nil
    
    override func setupView() {
        
        synchronizeButton.asTextButton("synchronizeNow".localize(), target: self, action: #selector(synchronizeNow))
        addSubviewCenteredBelow(synchronizeButton)
        var label = NSTextField(wrappingLabelWithString: "synchronizeHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeButton)
        
        synchronizeFromICloudButton.asTextButton("synchronizeFromCloud".localize(), target: self, action: #selector(synchronizeFromICloud))
        addSubviewCenteredBelow(synchronizeFromICloudButton, upperView: label, insets: OSInsets.doubleInsets)
        label = NSTextField(wrappingLabelWithString: "synchronizeFromCloudHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeFromICloudButton)
        
        synchronizeToICloudButton.asTextButton("synchronizeToCloud".localize(), target: self, action: #selector(synchronizeToICloud))
        addSubviewCenteredBelow(synchronizeToICloudButton, upperView: label)
        label = NSTextField(wrappingLabelWithString: "synchronizeToCloudHint".localize(table: "Hints")).asSmallLabel()
        label.alignment = .center
        addSubviewBelow(label, upperView: synchronizeToICloudButton)
        
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
    
    @objc func synchronizeFromICloud(){
        delegate?.synchronizeFromICloud()
    }
    
    @objc func synchronizeToICloud(){
        delegate?.synchronizeToICloud()
    }
    
    @objc func synchronizeNow(){
        delegate?.synchronizeNow()
    }
    
    @objc func clearICloud(){
        delegate?.clearICloud()
        
    }
    
    func updateButtonStates(){
        Task{
            let isOn = try await CKContainer.isConnected()
            synchronizeFromICloudButton.isEnabled = isOn
            synchronizeToICloudButton.isEnabled = isOn
            synchronizeButton.isEnabled = isOn
        }
    }
    
    func setSynchronizationSteps(_ value: Int) {
        maxSyncSteps = value
        currentSyncStep = 0
        progressView.doubleValue = 0
    }
    
    func nextSynchronizationStep() {
        currentSyncStep += 1
        progressView.doubleValue = Double(currentSyncStep) / Double(maxSyncSteps)
    }
    
}

