//
//  WorldMapExportController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 20/2/22.
//

import SwiftUI

class WorldMapExportController: UIViewController, UITextFieldDelegate {
    private let worldMapFileNameInput = UITextField()
    private var exportButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .large)
    private var goToAllWorldMapsViewButton = UIButton(type: .system)
    private var goToMainViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    var allWorldMapsController: AllWorldMapsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        worldMapFileNameInput.delegate = self
        worldMapFileNameInput.isUserInteractionEnabled = true
        worldMapFileNameInput.translatesAutoresizingMaskIntoConstraints = false
        worldMapFileNameInput.placeholder = "Custom File Name"
        worldMapFileNameInput.borderStyle = .roundedRect
        worldMapFileNameInput.autocorrectionType = .no
        worldMapFileNameInput.returnKeyType = .done
        worldMapFileNameInput.backgroundColor = .systemBackground
        view.addSubview(worldMapFileNameInput)
        
        exportButton = createPointCloudExportViewButton(iconName: "square.and.arrow.up")
        view.addSubview(exportButton)
        
        spinner.color = .white
        spinner.backgroundColor = .clear
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        goToAllWorldMapsViewButton = createPointCloudExportViewButton(iconName: "text.justify")
        view.addSubview(goToAllWorldMapsViewButton)
        
        goToMainViewButton = createPointCloudExportViewButton(iconName: "arrow.turn.down.left")
        view.addSubview(goToMainViewButton)
        
        NSLayoutConstraint.activate([
            worldMapFileNameInput.widthAnchor.constraint(equalToConstant: 300),
            worldMapFileNameInput.heightAnchor.constraint(equalToConstant: 45),
            worldMapFileNameInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            worldMapFileNameInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            exportButton.widthAnchor.constraint(equalToConstant: 40),
            exportButton.heightAnchor.constraint(equalToConstant: 40),
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            goToAllWorldMapsViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToAllWorldMapsViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToAllWorldMapsViewButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  40),
            goToAllWorldMapsViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            goToMainViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToMainViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToMainViewButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            goToMainViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    @objc func viewValueChanged(view: UIView) -> Void {
        switch view {
        case exportButton:
            executeExport()
            
        case goToAllWorldMapsViewButton:
            mainController.enteredAllWorldMapsViewFromMainView = false
            goToAllWorldMapsView()
            
        case goToMainViewButton:
            goToMainView()
            
        default:
            break
        }
    }
    
    // Text field delegate methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool { return true }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    private func dismissModal() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func beforeExport() -> Void {
        exportButton.isEnabled = false
        isModalInPresentation = true
    }
    private func onExportError(error: XError) -> Void {
        dismissModal()
        mainController.onExportError(error: error)
    }
    @objc func executeExport() -> Void {
        let worldMapFileName = !worldMapFileNameInput.text!.isEmpty ? worldMapFileNameInput.text : "untitled"
        
        let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let srcDirectory = docDirectory.appendingPathComponent("WorldMapTemp", isDirectory: true)
        let desDirectory = docDirectory.appendingPathComponent("WorldMaps", isDirectory: true)
        
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: desDirectory.absoluteString, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(at: desDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                fatalError("Failed to create a directory for storing world maps: \(error.self)")
            }
        }
        
        let srcFilePath = srcDirectory.appendingPathComponent("temp.arexperience", isDirectory: false)
        var desFilePath = desDirectory.appendingPathComponent("\(worldMapFileName ?? "untitled").arexperience", isDirectory: false)
        
        var renamingSuffix = 1
        var newName = worldMapFileName
        isDirectory = false
        while FileManager.default.fileExists(atPath: String(desFilePath.absoluteString.dropFirst(7)), isDirectory: &isDirectory) {
            newName = "\(worldMapFileName ?? "untitled")(\(renamingSuffix))"
            renamingSuffix += 1
            
            desFilePath = desDirectory.appendingPathComponent("\(newName ?? "untitled").arexperience", isDirectory: false)
        }
        
        do {
            try FileManager.default.moveItem(at: srcFilePath, to: desFilePath)
            mainController.worldMapURLs.append(desFilePath)
        }
        catch {
            fatalError("Failed to rename the world map file: \(error.self)")
        }
        
        dismissModal()
        mainController.export(url: desFilePath)
    }
    
    @objc func goToMainView() -> Void {
        dismissModal()
    }
    @objc func goToAllWorldMapsView() -> Void {
        dismissModal()
        mainController.goToAllWorldMapsView()
    }
}

private func createPointCloudExportViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .label
    button.addTarget(PointCloudExportController.self(), action: #selector(PointCloudExportController.viewValueChanged), for: .touchUpInside)
    return button
}

