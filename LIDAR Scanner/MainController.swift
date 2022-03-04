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
    var worldMapURLs = [URL]()
    var enteredAllWorldMapsViewFromMainView = true
    
    private var saveWorldMapButton = UIButton(type: .system)
    private var viewAllWorldMapsButton = UIButton(type: .system)
    private var toggleScanButton = UIButton(type: .system)
    private var toggleCameraViewButton = UIButton(type: .system)
    private var toggleParticlesButton = UIButton(type: .system)
    private var clearParticlesButton = UIButton(type: .system)
    private var exportPointCloudButton = UIButton(type: .system)
    private var supportButton = UIButton(type: .system)
    
    private let session = ARSession()
    var renderer: Renderer!
    
    // MARK: - UI Setting
    
    // Auto-hide the home indicator to maximize immersion in AR experiences
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device.")
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
        saveWorldMapButton = createMainViewButton(iconName: "location.slash")
        saveWorldMapButton.isEnabled = false
        view.addSubview(saveWorldMapButton)
        
        viewAllWorldMapsButton = createMainViewButton(iconName: "text.justify")
        view.addSubview(viewAllWorldMapsButton)
        
        toggleScanButton = createMainViewButton(iconName: "livephoto")
        view.addSubview(toggleScanButton)
        
        toggleCameraViewButton = createMainViewButton(iconName: "eye")
        view.addSubview(toggleCameraViewButton)
        
        toggleParticlesButton = createMainViewButton(iconName: "circle.grid.hex.fill")
        view.addSubview(toggleParticlesButton)
        
        clearParticlesButton = createMainViewButton(iconName: "trash")
        view.addSubview(clearParticlesButton)
        
        exportPointCloudButton = createMainViewButton(iconName: "square.and.arrow.up")
        view.addSubview(exportPointCloudButton)
        
        supportButton = createMainViewButton(iconName: "questionmark.circle")
        view.addSubview(supportButton)
        
        NSLayoutConstraint.activate([
            saveWorldMapButton.widthAnchor.constraint(equalToConstant: 40),
            saveWorldMapButton.heightAnchor.constraint(equalToConstant: 40),
            saveWorldMapButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            saveWorldMapButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            viewAllWorldMapsButton.widthAnchor.constraint(equalToConstant: 40),
            viewAllWorldMapsButton.heightAnchor.constraint(equalToConstant: 40),
            viewAllWorldMapsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 105),
            viewAllWorldMapsButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            toggleScanButton.widthAnchor.constraint(equalToConstant: 40),
            toggleScanButton.heightAnchor.constraint(equalToConstant: 40),
            toggleScanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleScanButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            toggleCameraViewButton.widthAnchor.constraint(equalToConstant: 40),
            toggleCameraViewButton.heightAnchor.constraint(equalToConstant: 32),
            toggleCameraViewButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40),
            toggleCameraViewButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -29),
            
            toggleParticlesButton.widthAnchor.constraint(equalToConstant: 40),
            toggleParticlesButton.heightAnchor.constraint(equalToConstant: 40),
            toggleParticlesButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 105),
            toggleParticlesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            clearParticlesButton.widthAnchor.constraint(equalToConstant: 40),
            clearParticlesButton.heightAnchor.constraint(equalToConstant: 40),
            clearParticlesButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -105),
            clearParticlesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            exportPointCloudButton.widthAnchor.constraint(equalToConstant: 40),
            exportPointCloudButton.heightAnchor.constraint(equalToConstant: 40),
            exportPointCloudButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            exportPointCloudButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            
            supportButton.widthAnchor.constraint(equalToConstant: 40),
            supportButton.heightAnchor.constraint(equalToConstant: 40),
            supportButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40),
            supportButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
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
    
    @objc func viewValueChanged(view: UIView) {
        switch view {
        case saveWorldMapButton:
            pauseScan()
            saveWorldMap()
            goToWorldMapExportView()
            
        case viewAllWorldMapsButton:
            pauseScan()
            enteredAllWorldMapsViewFromMainView = true
            goToAllWorldMapsView()
            
        case toggleScanButton:
            renderer.isInViewSceneMode = !renderer.isInViewSceneMode
            if !renderer.isInViewSceneMode {
                renderer.showParticles = true
                self.toggleParticlesButton.setBackgroundImage(.init(systemName: "circle.grid.hex.fill"), for: .normal)
                self.toggleScanButton.setBackgroundImage(.init(systemName: "livephoto.slash"), for: .normal)
            } else {
                self.toggleScanButton.setBackgroundImage(.init(systemName: "livephoto"), for: .normal)
            }
            
        case toggleCameraViewButton:
            renderer.rgbOn = !renderer.rgbOn
            let iconName = renderer.rgbOn ? "eye.slash" : "eye"
            toggleCameraViewButton.setBackgroundImage(.init(systemName: iconName), for: .normal)
            
        case toggleParticlesButton:
            renderer.showParticles = !renderer.showParticles
            if (!renderer.showParticles) {
                pauseScan()
            }
            let iconName = "circle.grid.hex" + (renderer.showParticles ? ".fill" : "")
            self.toggleParticlesButton.setBackgroundImage(.init(systemName: iconName), for: .normal)
            
        case clearParticlesButton:
            pauseScan()
            renderer.clearParticles()
            
        case exportPointCloudButton:
            pauseScan()
            goToPointCloudExportView()
        
        case supportButton:
            pauseScan()
            goToInstructionsView()
            
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        session.pause()
    }
    
    // MARK: - AR Session Observer
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable exporting world map only when the mapping status is good
        switch frame.worldMappingStatus {
        case .mapped, .extending:
            saveWorldMapButton.isEnabled = true
            saveWorldMapButton.setBackgroundImage(.init(systemName: "square.and.arrow.down"), for: .normal)
        
        default:
            saveWorldMapButton.isEnabled = false
            saveWorldMapButton.setBackgroundImage(.init(systemName: "location.slash"), for: .normal)
        }
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
            // Present an alert informing about the error that has occurred
            let alertController = UIAlertController(title: "AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restarting AR session.", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                if let configuration = self.session.configuration {
                    self.session.run(configuration, options: .resetSceneReconstruction)
                }
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - World Map Functionality
    
    private func generateWorldMapURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WorldMapTemp", isDirectory: true)
        
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: directory.absoluteString, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                fatalError("Failed to create a directory for storing world maps: \(error.self)")
            }
        }
        
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WorldMapTemp", isDirectory: true)
            .appendingPathComponent("temp.arexperience", isDirectory: false)
        
        return url
    }
    
    private func saveWorldMap() -> Void {
        session.getCurrentWorldMap { worldMap, error in
            guard let worldMapData = worldMap
            else {
                self.displayErrorMessage(error: XError.failedToGetWorldMap)
                return
            }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMapData, requiringSecureCoding: true)
                try data.write(to: self.generateWorldMapURL(), options: [.atomic])
            } catch {
                fatalError("Failed to save the current world map: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - MTK View Delegate

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

// MARK: - Extra Controller Functionality

extension MainController {
    func goToWorldMapExportView() -> Void {
        let worldMapExportController = WorldMapExportController()
        worldMapExportController.mainController = self
        present(worldMapExportController, animated: true, completion: nil)
    }
    func goToAllWorldMapsView() -> Void {
        let allWorldMapsController = AllWorldMapsController()
        allWorldMapsController.mainController = self
        present(allWorldMapsController, animated: true, completion: nil)
    }
    func goToPointCloudExportView() -> Void {
        let pointCloudExportController = PointCloudExportController()
        pointCloudExportController.mainController = self
        present(pointCloudExportController, animated: true, completion: nil)
    }
    func goToAllScansView() -> Void {
        let allScansController = AllScansController()
        allScansController.mainController = self
        present(allScansController, animated: true, completion: nil)
    }
    func goToInstructionsView() -> Void {
        let instructionsController = InstructionsController()
        instructionsController.mainController = self
        present(instructionsController, animated: true, completion: nil)
    }
    
    func loadSavedWorldMaps() {
        let worldMapDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WorldMaps", isDirectory: true)
        
        var isDirectory: ObjCBool = true
        if !FileManager.default.fileExists(atPath: worldMapDirectory.absoluteString, isDirectory: &isDirectory) {
            do {
                try FileManager.default.createDirectory(at: worldMapDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                fatalError("Failed to create a directory for storing world maps: \(error.self)")
            }
        }
        
        worldMapURLs = try! FileManager.default
            .contentsOfDirectory(at: worldMapDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
    }
    
    private func pauseScan() -> Void {
        renderer.isInViewSceneMode = true
        toggleScanButton.setBackgroundImage(.init(systemName: "livephoto"), for: .normal)
    }
    
    func displayErrorMessage(error: XError) -> Void {
        var title: String
        switch error {
        case .failedToGetWorldMap: title = "Failed to get world map data."
        case .noScanDone: title = "No scan data to save."
        case .alreadyExporting: title = "Exporting in progress, please wait."
        case .failedToExport: title = "Failed to export."
        }
        
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 1.75
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    func onExportError(error: XError) -> Void {
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
    func afterExport() -> Void {
        let err = renderer.savingError
        if err == nil {
            return export(url: renderer.savedPointCloudsURLs.last!)
        }
        try? FileManager.default.removeItem(at: renderer.savedPointCloudsURLs.last!)
        renderer.savedPointCloudsURLs.removeLast()
        onExportError(error: err!)
    }
}

// MARK: - Render Destination Provider

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

private func createMainViewButton(iconName: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setBackgroundImage(.init(systemName: iconName), for: .normal)
    button.tintColor = .white
    button.addTarget(MainController.self(), action: #selector(MainController.viewValueChanged), for: .touchUpInside)
    return button
}
func createLable(text: String) -> UILabel {
    let label = UILabel()
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .label
    return label
}

extension MTKView: RenderDestinationProvider { }

