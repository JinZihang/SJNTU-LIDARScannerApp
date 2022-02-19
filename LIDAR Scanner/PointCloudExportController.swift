//
//  PointCloudExportController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import SwiftUI

class PointCloudExportController: UIViewController, UITextFieldDelegate {
    private var particlesCountLabel = UILabel()
    private let pointCloudFileNameInput = UITextField()
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
        
        pointCloudFileNameInput.delegate = self
        pointCloudFileNameInput.isUserInteractionEnabled = true
        pointCloudFileNameInput.translatesAutoresizingMaskIntoConstraints = false
        pointCloudFileNameInput.placeholder = "Custom File Name"
        pointCloudFileNameInput.borderStyle = .roundedRect
        pointCloudFileNameInput.autocorrectionType = .no
        pointCloudFileNameInput.returnKeyType = .done
        pointCloudFileNameInput.backgroundColor = .systemBackground
        view.addSubview(pointCloudFileNameInput)
        
        exportButton = createPointCloudExportViewButton(iconName: "square.and.arrow.up")
        view.addSubview(exportButton)
        
        spinner.color = .white
        spinner.backgroundColor = .clear
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        goToAllScansViewButton = createPointCloudExportViewButton(iconName: "text.justify")
        view.addSubview(goToAllScansViewButton)
        
        goToMainViewButton = createPointCloudExportViewButton(iconName: "arrow.turn.down.left")
        view.addSubview(goToMainViewButton)
        
        NSLayoutConstraint.activate([
            particlesCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            particlesCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            pointCloudFileNameInput.widthAnchor.constraint(equalToConstant: 300),
            pointCloudFileNameInput.heightAnchor.constraint(equalToConstant: 45),
            pointCloudFileNameInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pointCloudFileNameInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
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
    
    @objc func viewValueChanged(view: UIView) -> Void {
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
        let pointCloudFileName = !pointCloudFileNameInput.text!.isEmpty ? pointCloudFileNameInput.text : "untitled"
        
        mainController.renderer.exportAsPlyFile(
            fileName: pointCloudFileName!,
            beforeGlobalThread: [beforeExport, spinner.startAnimating],
            afterGlobalThread: [dismissModal, spinner.stopAnimating, mainController.afterExport],
            errorCallback: onExportError)
    }
    
    @objc func goToMainView() -> Void {
        dismissModal()
    }
    @objc func goToAllScansView() -> Void {
        dismissModal()
        mainController.goToAllScansView()
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

