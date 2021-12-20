//
//  SaveController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import Foundation
import SwiftUI

class SaveController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    private var exportData = [URL]()
    
    private var particlesCountLabel = UILabel()
    private let fileNameInput = UITextField()
    private var formatData: [String] = ["Ascii", "Binary Little Endian", "Binary Big Endian"]
    private let formatPicker = UIPickerView()
    private var selectedFormat: String?
    private var saveFileButton = UIButton(type: .system)
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
        
        formatPicker.delegate = self
        formatPicker.dataSource = self
        formatPicker.translatesAutoresizingMaskIntoConstraints =  false
        formatPicker.delegate?.pickerView?(formatPicker, didSelectRow: 0, inComponent: 0)
        view.addSubview(formatPicker)
        
        saveFileButton = createSaveViewButton(iconName: "square.and.arrow.down")
        view.addSubview(saveFileButton)
        
        spinner.color = .white
        spinner.backgroundColor = .clear
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        goToAllScansViewButton = createSaveViewButton(iconName: "text.justify")
        view.addSubview(goToAllScansViewButton)
        
        goToMainViewButton = createSaveViewButton(iconName: "arrow.turn.down.left")
        view.addSubview(goToMainViewButton)
        
        NSLayoutConstraint.activate([
            particlesCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            particlesCountLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            fileNameInput.widthAnchor.constraint(equalToConstant: 300),
            fileNameInput.heightAnchor.constraint(equalToConstant: 45),
            fileNameInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fileNameInput.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            
            formatPicker.heightAnchor.constraint(equalToConstant: 230),
            formatPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formatPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            saveFileButton.widthAnchor.constraint(equalToConstant: 40),
            saveFileButton.heightAnchor.constraint(equalToConstant: 40),
            saveFileButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveFileButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
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
        case saveFileButton:
            executeSave()
            
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
    
    // Picker delegate methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return formatData.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return formatData[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { selectedFormat = formatData[row] }
    
    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func beforeSave() {
        saveFileButton.isEnabled = false
        isModalInPresentation = true
    }
    func onSaveError(error: XError) {
        dismissModal()
        mainController.onSaveError(error: error)
    }
    @objc func executeSave() -> Void {
        let fileName = !fileNameInput.text!.isEmpty ? fileNameInput.text : "untitled"
        let format = selectedFormat!
            .lowercased(with: .none)
            .split(separator: " ")
            .joined(separator: "_")
        
        mainController.renderer.saveAsPlyFile(
            fileName: fileName!,
            beforeGlobalThread: [beforeSave, spinner.startAnimating],
            afterGlobalThread: [dismissModal, spinner.stopAnimating, mainController.afterSave],
            errorCallback: onSaveError,
            format: format)
    }
    
    @objc func goToMainView() {
        dismissModal()
    }
    @objc func goToAllScansView() {
        dismissModal()
        mainController.goToAllScansView()
    }
}

func createSaveViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .label
    button.addTarget(SaveController.self(), action: #selector(SaveController.viewValueChanged), for: .touchUpInside)
    return button
}

