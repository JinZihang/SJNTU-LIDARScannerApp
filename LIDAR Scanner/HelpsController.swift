//
//  HelpsController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import Foundation
import SwiftUI

class HelpsController : UIViewController {
    private var helpsTitleLable = UILabel()
    private var toggleCameraImage = UIImageView()
    private var toggleCameraLable = UILabel()
    private var toggleParticlesImage = UIImageView()
    private var toggleParticlesLable = UILabel()
    private var toggleScanImage = UIImageView()
    private var toggleScanLable = UILabel()
    private var clearParticlesImage = UIImageView()
    private var clearParticlesLable = UILabel()
    private var saveFileImage = UIImageView()
    private var saveFileLable = UILabel()
    private var goToAllScansViewImage = UIImageView()
    private var goToAllScansViewLable = UILabel()
    private var goToPreviousViewImage = UIImageView()
    private var goToPreviousViewLable = UILabel()
    private var goToMainViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        helpsTitleLable = createLable(text: "Help")
        helpsTitleLable.font = .boldSystemFont(ofSize: 20)
        view.addSubview(helpsTitleLable)
        
        toggleCameraImage = createImage(iconName: "eye")
        view.addSubview(toggleCameraImage)
        toggleCameraLable = createLable(text: "Toggle camera view")
        view.addSubview(toggleCameraLable)
        
        toggleParticlesImage = createImage(iconName: "circle.grid.hex.fill")
        view.addSubview(toggleParticlesImage)
        toggleParticlesLable = createLable(text: "Toggle particles view")
        view.addSubview(toggleParticlesLable)
        
        toggleScanImage = createImage(iconName: "livephoto")
        view.addSubview(toggleScanImage)
        toggleScanLable = createLable(text: "Toggle scanning process")
        view.addSubview(toggleScanLable)
        
        clearParticlesImage = createImage(iconName: "trash")
        view.addSubview(clearParticlesImage)
        clearParticlesLable = createLable(text: "Clear particles")
        view.addSubview(clearParticlesLable)
        
        saveFileImage = createImage(iconName: "square.and.arrow.down")
        view.addSubview(saveFileImage)
        saveFileLable = createLable(text: "Open save view/Save file")
        view.addSubview(saveFileLable)
        
        goToAllScansViewImage = createImage(iconName: "text.justify")
        view.addSubview(goToAllScansViewImage)
        goToAllScansViewLable = createLable(text: "Open all-scans view")
        view.addSubview(goToAllScansViewLable)
        
        goToPreviousViewImage = createImage(iconName: "arrow.turn.down.left")
        view.addSubview(goToPreviousViewImage)
        goToPreviousViewLable = createLable(text: "Go to previous view")
        view.addSubview(goToPreviousViewLable)
        
        goToMainViewButton.translatesAutoresizingMaskIntoConstraints = false
        goToMainViewButton.setBackgroundImage(.init(systemName: "arrow.turn.down.left"), for: .normal)
        goToMainViewButton.tintColor = .label
        goToMainViewButton.addTarget(self, action: #selector(goToMainView), for: .touchUpInside)
        view.addSubview(goToMainViewButton)
        
        NSLayoutConstraint.activate([
            helpsTitleLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpsTitleLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            toggleCameraImage.widthAnchor.constraint(equalToConstant: 40),
            toggleCameraImage.heightAnchor.constraint(equalToConstant: 32),
            toggleCameraImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            toggleCameraImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            toggleCameraLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleCameraLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 66),
            
            toggleParticlesImage.widthAnchor.constraint(equalToConstant: 40),
            toggleParticlesImage.heightAnchor.constraint(equalToConstant: 40),
            toggleParticlesImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            toggleParticlesImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            toggleParticlesLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleParticlesLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 110),
            
            toggleScanImage.widthAnchor.constraint(equalToConstant: 40),
            toggleScanImage.heightAnchor.constraint(equalToConstant: 40),
            toggleScanImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            toggleScanImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            toggleScanLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleScanLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            
            clearParticlesImage.widthAnchor.constraint(equalToConstant: 40),
            clearParticlesImage.heightAnchor.constraint(equalToConstant: 40),
            clearParticlesImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            clearParticlesImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            clearParticlesLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            clearParticlesLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            
            saveFileImage.widthAnchor.constraint(equalToConstant: 40),
            saveFileImage.heightAnchor.constraint(equalToConstant: 40),
            saveFileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            saveFileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 250),
            saveFileLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveFileLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 260),
            
            goToAllScansViewImage.widthAnchor.constraint(equalToConstant: 40),
            goToAllScansViewImage.heightAnchor.constraint(equalToConstant: 40),
            goToAllScansViewImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            goToAllScansViewImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 300),
            goToAllScansViewLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goToAllScansViewLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 310),
            
            goToPreviousViewImage.widthAnchor.constraint(equalToConstant: 40),
            goToPreviousViewImage.heightAnchor.constraint(equalToConstant: 40),
            goToPreviousViewImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -200),
            goToPreviousViewImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 350),
            goToPreviousViewLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goToPreviousViewLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 360),
            
            goToMainViewButton.widthAnchor.constraint(equalToConstant: 40),
            goToMainViewButton.heightAnchor.constraint(equalToConstant: 40),
            goToMainViewButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            goToMainViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    func dismissModal() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func goToMainView() {
        dismissModal()
    }
}

func createImage(iconName: String) -> UIImageView {
    let image = UIImageView()
    image.image = .init(systemName: iconName)
    image.translatesAutoresizingMaskIntoConstraints = false
    image.tintColor = .label
    return image
}

func createLable(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .label
    return label
}

