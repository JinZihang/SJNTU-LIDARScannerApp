//
//  ViewController.swift
//  LIDAR Scanner
//
//  Created by Zihang Jin on 12/12/21.
//

import UIKit
import Metal
import MetalKit
import ARKit

final class MainController: UIViewController, ARSessionDelegate {
    private var toggleScanButton = UIButton(type: .system)
    private var toggleCameraViewButton = UIButton(type: .system)
    private var toggleParticlesButton = UIButton(type: .system)
    private var clearButton = UIButton(type: .system)
    private var saveButton = UIButton(type: .system)
    private var supportButton = UIButton(type: .system)
    
    private let session = ARSession()
    var renderer: Renderer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        // Set the view's delegate
        session.delegate = self
        
        // Set the view to use the default device
        if let view = self.view as? MTKView {
            view.device = device
            view.backgroundColor = UIColor.clear
            
            // Enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: view.device!, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
        }
        
        // Add buttons to the view
        supportButton = createMainViewButton(iconName: "questionmark.circle")
        view.addSubview(supportButton)
        
        toggleCameraViewButton = createMainViewButton(iconName: "eye")
        view.addSubview(toggleCameraViewButton)
        
        toggleParticlesButton = createMainViewButton(iconName: "circle.grid.hex.fill")
        view.addSubview(toggleParticlesButton)
        
        toggleScanButton = createMainViewButton(iconName: "livephoto")
        view.addSubview(toggleScanButton)
        
        clearButton = createMainViewButton(iconName: "trash")
        view.addSubview(clearButton)
        
        saveButton = createMainViewButton(iconName: "square.and.arrow.down")
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            supportButton.widthAnchor.constraint(equalToConstant: 40),
            supportButton.heightAnchor.constraint(equalToConstant: 40),
            supportButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            supportButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            toggleCameraViewButton.widthAnchor.constraint(equalToConstant: 40),
            toggleCameraViewButton.heightAnchor.constraint(equalToConstant: 32),
            toggleCameraViewButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            toggleCameraViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            toggleParticlesButton.widthAnchor.constraint(equalToConstant: 40),
            toggleParticlesButton.heightAnchor.constraint(equalToConstant: 40),
            toggleParticlesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 105),
            toggleParticlesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            toggleScanButton.widthAnchor.constraint(equalToConstant: 40),
            toggleScanButton.heightAnchor.constraint(equalToConstant: 40),
            toggleScanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleScanButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            clearButton.widthAnchor.constraint(equalToConstant: 40),
            clearButton.heightAnchor.constraint(equalToConstant: 40),
            clearButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -105),
            clearButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            saveButton.widthAnchor.constraint(equalToConstant: 40),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable the scene depth frame-semantic
        configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]

        // Run the view's session
        session.run(configuration)
        
        // The screen shouldn't dim during AR experiences
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    @objc
    func viewValueChanged(view: UIView) {
        switch view {
        case toggleScanButton:
            renderer.isInViewSceneMode = !renderer.isInViewSceneMode
            if !renderer.isInViewSceneMode {
                renderer.showParticles = true
                self.toggleParticlesButton.setBackgroundImage(
                    .init(systemName: "circle.grid.hex.fill"), for: .normal)
                self.toggleScanButton.setBackgroundImage(
                    .init(systemName: "livephoto.slash"), for: .normal)
            } else {
                self.toggleScanButton.setBackgroundImage(
                    .init(systemName: "livephoto"), for: .normal)
            }
            
        case toggleCameraViewButton:
            renderer.rgbOn = !renderer.rgbOn
            let iconName = renderer.rgbOn ? "eye.slash" : "eye"
            toggleCameraViewButton.setBackgroundImage(.init(systemName: iconName), for: .normal)
            
        case toggleParticlesButton:
            renderer.showParticles = !renderer.showParticles
            if (!renderer.showParticles) {
                renderer.isInViewSceneMode = true
                self.toggleScanButton.setBackgroundImage(.init(systemName: "livephoto"), for: .normal)
            }
            let iconName = "circle.grid.hex" + (renderer.showParticles ? ".fill" : "")
            self.toggleParticlesButton.setBackgroundImage(.init(systemName: iconName), for: .normal)
            
        case clearButton:
            renderer.isInViewSceneMode = true
            toggleScanButton.setBackgroundImage(.init(systemName: "livephoto"), for: .normal)
            renderer.clearParticles()
            
        case saveButton:
            renderer.isInViewSceneMode = true
            toggleScanButton.setBackgroundImage(.init(systemName: "livephoto"), for: .normal)
            goToSaveView()
        
        case supportButton:
            renderer.isInViewSceneMode = true
            toggleScanButton.setBackgroundImage(.init(systemName: "livephoto"), for: .normal)
            goToHelpView()
            
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }
    
    // Auto-hide the home indicator to maximize immersion in AR experiences
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
    
    
// MARK: - MTKViewDelegate

extension MainController: MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }
    
    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.draw()
    }
}

// MARK: - Added controller functionality

extension MainController {
    func goToSaveView() {
        let saveController = SaveController()
        saveController.mainController = self
        present(saveController, animated: true, completion: nil)
    }
    func goToAllScansView() {
        let allScansController = AllScansController()
        allScansController.mainController = self
        present(allScansController, animated: true, completion: nil)
    }
    func goToHelpView() {
        let helpsController = HelpsController()
        helpsController.mainController = self
        present(helpsController, animated: true, completion: nil)
    }
    
    func displayErrorMessage(error: XError) -> Void {
        var title: String
        switch error {
            case .alreadySavingFile: title = "Saving in progress, please wait."
            case .noScanDone: title = "No scan data to save."
            case.savingFailed: title = "Saving failed."
        }
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.75
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    func onSaveError(error: XError) {
        displayErrorMessage(error: error)
        renderer.savingError = nil
    }
    func export(url: URL) -> Void {
        present(
            UIActivityViewController(
                activityItems: [url as Any],
                applicationActivities: .none),
            animated: true)
    }
    func afterSave() -> Void {
        let err = renderer.savingError
        if err == nil {
            return export(url: renderer.savedCloudURLs.last!)
        }
        try? FileManager.default.removeItem(at: renderer.savedCloudURLs.last!)
        renderer.savedCloudURLs.removeLast()
        onSaveError(error: err!)
    }
}

// MARK: - RenderDestinationProvider

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

func createMainViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .label
    button.addTarget(MainController.self(), action: #selector(MainController.viewValueChanged), for: .touchUpInside)
    return button
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

extension MTKView: RenderDestinationProvider { }

