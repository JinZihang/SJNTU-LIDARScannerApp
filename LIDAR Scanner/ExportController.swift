//
//  ExportController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import Foundation
import SwiftUI

class ExportController: UIViewController, UITextFieldDelegate {
    private var exportData = [URL]()
    
    private var particlesCountLabel = UILabel()
    private let fileNameInput = UITextField()
    private var exportButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .large)
    private var goToAllScansViewButton = UIButton(type: .system)
    private var goToMainViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        particlesCountLabel = createLable(text: "Scanned \(mainController.renderer.highConfCount) Points")
        view.addSubview(particlesCountLabel)
        
        fileNameInput.delegate = self
        fileNameInput.isUserInteractionEnabled = true
        fileNameInput.translatesAutoresizingMaskIntoConstraints = false
        fileNameInput.placeholder = "Custom File Name"
        fileNameInput.borderStyle = .roundedRect
        fileNameInput.autocorrectionType = .no
        fileNameInput.returnKeyType = .done
        fileNameInput.backgroundColor = .systemBackground
        view.addSubview(fileNameInput)
        
        exportButton = createExportViewButton(iconName: "square.and.arrow.up")
        view.addSubview(exportButton)
        
        spinner.color = .white
        spinner.backgroundColor = .clear
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        goToAllScansViewButton = createExportViewButton(iconName: "text.justify")
        view.addSubview(goToAllScansViewButton)
        
        goToMainViewButton = createExportViewButton(iconName: "arrow.turn.down.left")
        view.addSubview(goToMainViewButton)
        
        NSLayoutConstraint.activate([
            particlesCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            particlesCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            fileNameInput.widthAnchor.constraint(equalToConstant: 300),
            fileNameInput.heightAnchor.constraint(equalToConstant: 45),
            fileNameInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fileNameInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            exportButton.widthAnchor.constraint(equalToConstant: 40),
            exportButton.heightAnchor.constraint(equalToConstant: 40),
            exportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exportButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            goToAllScansViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToAllScansViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToAllScansViewButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant:  40),
            goToAllScansViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            goToMainViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToMainViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToMainViewButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            goToMainViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    @objc
    func viewValueChanged(view: UIView) {
        switch view {
        case exportButton:
            executeExport()
            
        case goToAllScansViewButton:
            goToAllScansView()
            
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
    
    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func beforeExport() {
        exportButton.isEnabled = false
        isModalInPresentation = true
    }
    func onExportError(error: XError) {
        dismissModal()
        mainController.onExportError(error: error)
    }
    @objc func executeExport() -> Void {
        let fileName = !fileNameInput.text!.isEmpty ? fileNameInput.text : "untitled"
        
        mainController.renderer.exportAsPlyFile(
            fileName: fileName!,
            beforeGlobalThread: [beforeExport, spinner.startAnimating],
            afterGlobalThread: [dismissModal, spinner.stopAnimating, mainController.afterExport],
            errorCallback: onExportError)
    }
    
    @objc func goToMainView() {
        dismissModal()
    }
    @objc func goToAllScansView() {
        dismissModal()
        mainController.goToAllScansView()
    }
}

func createExportViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .label
    button.addTarget(ExportController.self(), action: #selector(ExportController.viewValueChanged), for: .touchUpInside)
    return button
}

