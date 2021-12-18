//
//  ExportController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 18/12/21.
//

import Foundation
import SwiftUI

class ExportController : UIViewController {
    private var exportData = [URL]()
    private var selectedExport: URL?
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        mainController.renderer.loadSavedClouds()
        exportData = mainController.renderer.savedCloudURLs
    }
   
    func onSaveError(error: XError) {
        dismissModal()
        mainController.onSaveError(error: error)
    }
    func dismissModal() { self.dismiss(animated: true, completion: nil) }
    @objc func executeExport() {
        guard selectedExport != nil else { return }
        dismissModal()
        mainController.export(url: selectedExport!)
    }
}

