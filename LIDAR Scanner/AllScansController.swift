//
//  AllScansController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import SwiftUI

class AllScansController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private var exportData = [URL]()
    
    private var scanCountLabel = UILabel()
    private let scanPicker = UIPickerView()
    private var selectedScanIndex : Int?
    private var selectedScan: URL?
    private var deleteFileButton = UIButton(type: .system)
    private var exportButton = UIButton(type: .system)
    private var goToExportViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        mainController.renderer.loadSavedPointClouds()
        exportData = mainController.renderer.savedPointCloudsURLs
        
        scanCountLabel = exportData.count < 2 ? createLable(text: "\(exportData.count) Previous Scan Found") : createLable(text: "\(exportData.count) Previous Scans Found")
        view.addSubview(scanCountLabel)
        
        scanPicker.delegate = self
        scanPicker.dataSource = self
        scanPicker.translatesAutoresizingMaskIntoConstraints = false
        if !exportData.isEmpty {
            scanPicker.delegate?.pickerView?(scanPicker, didSelectRow: 0, inComponent: 0)
        }
        view.addSubview(scanPicker)
        
        deleteFileButton = createAllScansViewButton(iconName: "trash")
        view.addSubview(deleteFileButton)
        
        exportButton = createAllScansViewButton(iconName: "square.and.arrow.up")
        view.addSubview(exportButton)
        
        goToExportViewButton = createAllScansViewButton(iconName: "arrow.turn.down.left")
        view.addSubview(goToExportViewButton)
        
        NSLayoutConstraint.activate([
            scanCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            scanPicker.heightAnchor.constraint(equalToConstant: 230),
            scanPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            deleteFileButton.widthAnchor.constraint(equalToConstant: 40),
            deleteFileButton.heightAnchor.constraint(equalToConstant: 40),
            deleteFileButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            deleteFileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            exportButton.widthAnchor.constraint(equalToConstant: 40),
            exportButton.heightAnchor.constraint(equalToConstant: 40),
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            goToExportViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToExportViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToExportViewButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            goToExportViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    @objc func viewValueChanged(view: UIView) -> Void {
        switch view {
        case deleteFileButton:
            executeDelete()
            
        case exportButton:
            executeExport()
            
        case goToExportViewButton:
            goToExportView()
            
        default:
            break
        }
    }
    
    // Picker delegate methods
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
    
    private func dismissModal() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func executeDelete() -> Void {
        guard selectedScan != nil else { return }

        try! FileManager.default.removeItem(at: selectedScan!)
        mainController.renderer.savedPointCloudsURLs.remove(at: selectedScanIndex!)
        exportData.remove(at: selectedScanIndex!)
        scanPicker.reloadAllComponents()
        
        if selectedScanIndex == 0  {
            scanPicker.delegate?.pickerView?(scanPicker, didSelectRow: 0, inComponent: 0)
        } else if selectedScanIndex == exportData.count {
            scanPicker.delegate?.pickerView?(scanPicker, didSelectRow: selectedScanIndex!-1, inComponent: 0)
        } else {
            scanPicker.delegate?.pickerView?(scanPicker, didSelectRow: selectedScanIndex!, inComponent: 0)
        }
        
        if (exportData.count < 2) {
            scanCountLabel.text = "\(exportData.count) Previous Scan Found"
        } else {
            scanCountLabel.text = "\(exportData.count) Previous Scans Found"
        }
    }
    private func onExportError(error: XError) -> Void {
        dismissModal()
        mainController.onExportError(error: error)
    }
    @objc func executeExport() -> Void {
        guard selectedScan != nil else { return }
        dismissModal()
        mainController.export(url: selectedScan!)
    }
    
    @objc func goToExportView() -> Void {
        dismissModal()
        mainController.goToPointCloudExportView()
    }
}

private func createAllScansViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .label
    button.addTarget(AllScansController.self(), action: #selector(AllScansController.viewValueChanged), for: .touchUpInside)
    return button
}

