//
//  SceneManager.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/31/25.
//

import SwiftUI
import SceneKit

@Observable
final class SceneManager {
    static let shared = SceneManager()
    var sceneView: SCNView
    
    private init() {
        sceneView = SCNView()
        setupSceneView()
    }
    
    private func setupSceneView() {
        let options: [SCNSceneSource.LoadingOption: Any] = [
            .createNormalsIfAbsent: false,
            .flattenScene: true,
            .preserveOriginalTopology: true,
            .convertUnitsToMeters: 1.0,
            .animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay
        ]
        
        guard let scene = SCNScene(named: "Male_Full.dae",
                                 inDirectory: "",
                                 options: options) else {
            fatalError("Failed to find model file.")
        }
        
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear
        sceneView.antialiasingMode = .multisampling2X
        sceneView.preferredFramesPerSecond = 30
        sceneView.rendersContinuously = false
        sceneView.isPlaying = false
        
        sceneView.layer.borderWidth = 0
        sceneView.isJitteringEnabled = false
        sceneView.defaultCameraController.maximumVerticalAngle = 0.001
        
        scene.rootNode.flattenedClone()
    }
}
