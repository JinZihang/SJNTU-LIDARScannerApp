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
    
    private let particlesCountLabel = UILabel()
    private let fileNameInput = UITextField()
    private var formatData: [String] = ["Ascii", "Binary Little Endian", "Binary Big Endian"]
    private let formatPicker = UIPickerView()
    private var selectedFormat: String?
    private let saveFileButton = UIButton(type: .system)
    private let spinner = UIActivityIndicatorView(style: .large)
    private let goToAllScansViewButton = UIButton(type: .system)
    private let goToMainViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        particlesCountLabel.text = "Scanned \(mainController.renderer.highConfCount) Points"
        particlesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        particlesCountLabel.textColor = .label
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
        
        saveFileButton.translatesAutoresizingMaskIntoConstraints = false
        saveFileButton.setBackgroundImage(.init(systemName: "square.and.arrow.down"), for: .normal)
        saveFileButton.tintColor = .label
        saveFileButton.addTarget(self, action: #selector(executeSave), for: .touchUpInside)
        view.addSubview(saveFileButton)
        
        spinner.color = .white
        spinner.backgroundColor = .clear
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        goToAllScansViewButton.translatesAutoresizingMaskIntoConstraints = false
        goToAllScansViewButton.setBackgroundImage(.init(systemName: "text.justify"), for: .normal)
        goToAllScansViewButton.tintColor = .label
        goToAllScansViewButton.addTarget(self, action: #selector(goToAllScansView), for: .touchUpInside)
        view.addSubview(goToAllScansViewButton)
        
        goToMainViewButton.translatesAutoresizingMaskIntoConstraints = false
        goToMainViewButton.setBackgroundImage(.init(systemName: "arrow.turn.down.left"), for: .normal)
        goToMainViewButton.tintColor = .label
        goToMainViewButton.addTarget(self, action: #selector(goToMainView), for: .touchUpInside)
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

