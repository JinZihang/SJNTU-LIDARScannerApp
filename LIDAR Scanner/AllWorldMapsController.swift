//
//  AllWorldMapsController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 20/2/22.
//

import SwiftUI

class AllWorldMapsController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var exportData = [URL]()
    
    private var worldMapCountLabel = UILabel()
    let worldMapPicker = UIPickerView()
    private var selectedWorldMapIndex : Int?
    private var selectedWorldMap: URL?
    private var deleteFileButton = UIButton(type: .system)
    private var exportButton = UIButton(type: .system)
    private var goToPreviousViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        mainController.loadSavedWorldMaps()
        exportData = mainController.worldMapURLs
        
        worldMapCountLabel = exportData.count < 2 ? createLable(text: "\(exportData.count) Previous World Map Found") : createLable(text: "\(exportData.count) Previous World Maps Found")
        view.addSubview(worldMapCountLabel)
        
        worldMapPicker.delegate = self
        worldMapPicker.dataSource = self
        worldMapPicker.translatesAutoresizingMaskIntoConstraints = false
        if !exportData.isEmpty {
            worldMapPicker.delegate?.pickerView?(worldMapPicker, didSelectRow: 0, inComponent: 0)
        }
        view.addSubview(worldMapPicker)
        
        deleteFileButton = createAllWorldMapsViewButton(iconName: "trash")
        view.addSubview(deleteFileButton)
        
        exportButton = createAllWorldMapsViewButton(iconName: "square.and.arrow.up")
        view.addSubview(exportButton)
        
        goToPreviousViewButton = createAllWorldMapsViewButton(iconName: "arrow.turn.down.left")
        view.addSubview(goToPreviousViewButton)
        
        NSLayoutConstraint.activate([
            worldMapCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            worldMapCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            worldMapPicker.heightAnchor.constraint(equalToConstant: 230),
            worldMapPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            worldMapPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            deleteFileButton.widthAnchor.constraint(equalToConstant: 40),
            deleteFileButton.heightAnchor.constraint(equalToConstant: 40),
            deleteFileButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            deleteFileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            exportButton.widthAnchor.constraint(equalToConstant: 40),
            exportButton.heightAnchor.constraint(equalToConstant: 40),
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            goToPreviousViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToPreviousViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToPreviousViewButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            goToPreviousViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    @objc func viewValueChanged(view: UIView) -> Void {
        switch view {
        case deleteFileButton:
            executeDelete()
            
        case exportButton:
            executeExport()
            
        case goToPreviousViewButton:
            goToPreviousView()
            
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
        selectedWorldMapIndex = row
        selectedWorldMap = !exportData.isEmpty ? exportData[row] : nil
    }
    
    private func dismissModal() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func executeDelete() -> Void {
        guard selectedWorldMap != nil else { return }

        try! FileManager.default.removeItem(at: selectedWorldMap!)
        mainController.worldMapURLs.remove(at: selectedWorldMapIndex!)
        exportData.remove(at: selectedWorldMapIndex!)
        worldMapPicker.reloadAllComponents()
        
        if selectedWorldMapIndex == 0  {
            worldMapPicker.delegate?.pickerView?(worldMapPicker, didSelectRow: 0, inComponent: 0)
        } else if selectedWorldMapIndex == exportData.count {
            worldMapPicker.delegate?.pickerView?(worldMapPicker, didSelectRow: selectedWorldMapIndex!-1, inComponent: 0)
        } else {
            worldMapPicker.delegate?.pickerView?(worldMapPicker, didSelectRow: selectedWorldMapIndex!, inComponent: 0)
        }
        
        if (exportData.count < 2) {
            worldMapCountLabel.text = "\(exportData.count) Previous World Map Found"
        } else {
            worldMapCountLabel.text = "\(exportData.count) Previous World Maps Found"
        }
    }
    private func onExportError(error: XError) -> Void {
        dismissModal()
        mainController.onExportError(error: error)
    }
    @objc func executeExport() -> Void {
        guard selectedWorldMap != nil else { return }
        dismissModal()
        mainController.export(url: selectedWorldMap!)
    }
    
    @objc func goToPreviousView() -> Void {
        dismissModal()
        if !mainController.enteredAllWorldMapsViewFromMainView {
            mainController.goToWorldMapExportView()
        }
    }
}

private func createAllWorldMapsViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .label
    button.addTarget(AllScansController.self(), action: #selector(AllScansController.viewValueChanged), for: .touchUpInside)
    return button
}

