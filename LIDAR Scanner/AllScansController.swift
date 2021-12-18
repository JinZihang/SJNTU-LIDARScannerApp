//
//  AllScansController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import Foundation
import SwiftUI

class AllScansController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private var exportData = [URL]()
    
    private let scanCountLabel = UILabel()
    private let allScansPicker = UIPickerView()
    private var selectedScanIndex : Int?
    private var selectedScan: URL?
    private let deleteFileButton = UIButton(type: .system)
    private let saveFileButton = UIButton(type: .system)
    private let goToSaveViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        mainController.renderer.loadSavedClouds()
        exportData = mainController.renderer.savedCloudURLs
        
        scanCountLabel.text = "\(exportData.count) Scans Found"
        scanCountLabel.translatesAutoresizingMaskIntoConstraints = false
        scanCountLabel.textColor = .label
        view.addSubview(scanCountLabel)
        
        allScansPicker.delegate = self
        allScansPicker.dataSource = self
        allScansPicker.translatesAutoresizingMaskIntoConstraints = false
        if !exportData.isEmpty {
            allScansPicker.delegate?.pickerView?(allScansPicker, didSelectRow: 0, inComponent: 0)
        }
        view.addSubview(allScansPicker)
        
        deleteFileButton.translatesAutoresizingMaskIntoConstraints = false
        deleteFileButton.setBackgroundImage(.init(systemName: "trash"), for: .normal)
        deleteFileButton.tintColor = .label
        deleteFileButton.addTarget(self, action: #selector(executeDelete), for: .touchUpInside)
        view.addSubview(deleteFileButton)
        
        saveFileButton.translatesAutoresizingMaskIntoConstraints = false
        saveFileButton.setBackgroundImage(.init(systemName: "square.and.arrow.down"), for: .normal)
        saveFileButton.tintColor = .label
        saveFileButton.addTarget(self, action: #selector(executeSave), for: .touchUpInside)
        view.addSubview(saveFileButton)
        
        goToSaveViewButton.translatesAutoresizingMaskIntoConstraints = false
        goToSaveViewButton.setBackgroundImage(.init(systemName: "arrow.turn.down.left"), for: .normal)
        goToSaveViewButton.tintColor = .label
        goToSaveViewButton.addTarget(self, action: #selector(goToSaveView), for: .touchUpInside)
        view.addSubview(goToSaveViewButton)
        
        NSLayoutConstraint.activate([
            scanCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            allScansPicker.heightAnchor.constraint(equalToConstant: 230),
            allScansPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            allScansPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            saveFileButton.widthAnchor.constraint(equalToConstant: 40),
            saveFileButton.heightAnchor.constraint(equalToConstant: 40),
            saveFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveFileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            deleteFileButton.widthAnchor.constraint(equalToConstant: 40),
            deleteFileButton.heightAnchor.constraint(equalToConstant: 40),
            deleteFileButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            deleteFileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            saveFileButton.widthAnchor.constraint(equalToConstant: 40),
            saveFileButton.heightAnchor.constraint(equalToConstant: 40),
            saveFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveFileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            goToSaveViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToSaveViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToSaveViewButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            goToSaveViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exportData.count
    }
    func pickerView(_ pickerView: UIPickerView,titleForRow row: Int, forComponent component: Int) -> String? {
        return exportData[row].lastPathComponent
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedScanIndex = row
        selectedScan = !exportData.isEmpty ? exportData[row] : nil
    }
    
    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func executeDelete() -> Void {
        guard selectedScan != nil else { return }

        try! FileManager.default.removeItem(at: selectedScan!)
        mainController.renderer.savedCloudURLs.remove(at: selectedScanIndex!)
        exportData.remove(at: selectedScanIndex!)
        allScansPicker.reloadAllComponents()
        
        if selectedScanIndex == 0  {
            allScansPicker.delegate?.pickerView?(allScansPicker, didSelectRow: 0, inComponent: 0)
        } else if selectedScanIndex == exportData.count {
            allScansPicker.delegate?.pickerView?(allScansPicker, didSelectRow: selectedScanIndex!-1, inComponent: 0)
        } else {
            allScansPicker.delegate?.pickerView?(allScansPicker, didSelectRow: selectedScanIndex!, inComponent: 0)
        }
        
        scanCountLabel.text = "\(exportData.count) Scans Found"
    }
    func onSaveError(error: XError) {
        dismissModal()
        mainController.onSaveError(error: error)
    }
    @objc func executeSave() {
        guard selectedScan != nil else { return }
        dismissModal()
        mainController.export(url: selectedScan!)
    }
    
    @objc func goToSaveView() {
        dismissModal()
        mainController.goToSaveView()
    }
}

