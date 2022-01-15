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
    private var goToMainViewButton = UIButton(type: .system)
    
    var mainController: MainController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        helpsTitleLable = createLable(text: "Help")
        view.addSubview(helpsTitleLable)
        
        goToMainViewButton.translatesAutoresizingMaskIntoConstraints = false
        goToMainViewButton.setBackgroundImage(.init(systemName: "arrow.turn.down.left"), for: .normal)
        goToMainViewButton.tintColor = .label
        goToMainViewButton.addTarget(self, action: #selector(goToMainView), for: .touchUpInside)
        view.addSubview(goToMainViewButton)
        
        NSLayoutConstraint.activate([
            helpsTitleLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpsTitleLable.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
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

