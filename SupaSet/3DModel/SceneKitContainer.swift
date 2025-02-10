//
//  SceneKitContainer.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/14/25.
//


import Foundation
import SceneKit
import SwiftUI
// ViewWrapper to use UIView in SwiftUI
struct ViewWrapper: UIViewRepresentable {
    let view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct SceneKitContainer: UIViewRepresentable {
    let sceneManager: SceneManager = .shared
    let isTapGestureEnabled : Bool?
    func makeUIView(context: Context) -> SCNView {
        let sceneView = sceneManager.sceneView
        addGestures(to: sceneView, context: context)
        return sceneView
    }
        
    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.tapGesture?.isEnabled = isTapGestureEnabled ?? false
    }
    private func addGestures(to view: SCNView, context: Context) {
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        context.coordinator.tapGesture = tapGesture  // Store the gesture in the coordinator
    }
    
    private func setupScene() -> SCNScene {
        let options: [SCNSceneSource.LoadingOption: Any] = [
                    .createNormalsIfAbsent: false,    // Assumes model has normals
                    .flattenScene: true,
                    .preserveOriginalTopology: true,  // Better for GPU memory
                    .convertUnitsToMeters: 1.0,
                    .animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay
                ]
        guard let scene = SCNScene(named: "Male_Full.dae",
                                   inDirectory: "",
                                   options: options) else {
            fatalError("Failed to find model file.")
        }
        return scene
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: SceneKitContainer
        var tapGesture: UITapGestureRecognizer?
        init(_ parent: SceneKitContainer) {
            self.parent = parent
        }
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            let p = gestureRecognize.location(in: parent.sceneManager.sceneView)
            let hitResults = parent.sceneManager.sceneView.hitTest(p, options: [:])
            
            if let result = hitResults.first, let nodeName = result.node.name, let muscleGroup = MuscleGroups.muscleMappings.first(where: { $1.contains(nodeName) })?.key {
                parent.sceneManager.sceneView.scene?.highlightTargetedMuscles(primaryMuscles: [muscleGroup], secondaryMuscles: [])
            }
        }
    }
    // MARK: - Memory Cleanup
    func dismantleUIView(_ uiView: SCNView, context: Context) {
        uiView.scene?.rootNode.enumerateHierarchy { node, _ in
            node.geometry?.materials.forEach { $0.removeAllAnimations() }
            node.geometry = nil
        }
        uiView.scene = nil
        uiView.removeFromSuperview()
        SCNTransaction.flush()
    }
}

extension SCNScene {
    
    func highlightMaterial(for muscles: [String], color: UIColor) {
        rootNode.enumerateChildNodes { node, _ in
            for muscle in muscles {
                if node.name == muscle {
                    node.geometry?.materials.forEach { material in
                        material.diffuse.contents = color
                    }
                }
            }
        }
    }
    
    func highlightTargetedMuscles(primaryMuscles : [MuscleGroup], secondaryMuscles : [MuscleGroup]) {
        //         Define the default color for all muscles (e.g., gray)
        let defaultColor = UIColor.gray
        
        // Populate the dictionary with specific colors for targeted muscles
        var muscleColorMapping = [String: UIColor]()
        
        // Secondary muscles get yellow
        for muscle in secondaryMuscles {
            let muscleNames = MuscleGroups.muscleMappings[muscle] ?? []
            muscleNames.forEach { muscleColorMapping[$0] = UIColor.yellow }
        }
        
        // Primary muscles get red
        for muscle in primaryMuscles {
            let muscleNames = MuscleGroups.muscleMappings[muscle] ?? []
            muscleNames.forEach { muscleColorMapping[$0] = UIColor.red }
        }
        
        // Enumerate all nodes and set the default color or the specific color if the node is in the dictionary
        rootNode.enumerateChildNodes { node, _ in
            let color = muscleColorMapping[node.name ?? ""] ?? defaultColor
            node.geometry?.materials.forEach { material in
                material.diffuse.contents = color
            }
        }
    }
    func highlightMuscleIntensity(muscleIntensity: [MuscleGroup: Double]) {
        // Find the maximum intensity across all muscles
        let maxIntensity = muscleIntensity.values.max() ?? 0
        // Apply visual effects to each muscle node based on intensity
        
        for (muscleGroup, nodeNames) in MuscleGroups.muscleMappings {
            let intensity = muscleIntensity[muscleGroup] ?? 0 // Default intensity to 0 if not provided
            if let color = colorForIntensity(intensity, maxIntensity: maxIntensity) {
                rootNode.enumerateChildNodes { node, _ in
                    if (node.name).map(nodeNames.contains) ?? false {
                        node.geometry?.materials.forEach { material in
                            material.diffuse.contents = color
                        }
                    }
                }
            }
        }
    }
    
    func colorForIntensity(_ intensity: Double, maxIntensity: Double) -> UIColor? {
        guard intensity > 0 else { return nil }
        
        // Apply logarithmic scaling to the intensity values
        let scaledIntensity = log(intensity + 1) / log(maxIntensity + 1)  // Log scale with 1 added to avoid log(0)
        // Apply an exponent to further exaggerate the differences
        let exaggeratedIntensity = pow(scaledIntensity, 1.5)  // Exponentiation increases the intensity differences
        
        // Normalize the exaggerated intensity to 0-1 range
        let normalized = CGFloat(exaggeratedIntensity)
        
        // Ensure the red component is always at its highest value and other components adjust based on intensity
        let red = 1.0 // Ensure the lowest intensity is not too green
        let green = 1.0 - normalized
        let blue = 1.0 - normalized
        
        // Adjust opacity to make the color more vivid as intensity increases
        let alpha: CGFloat = 0.7 + (normalized * 0.3)  // Opacity increases with intensity
        
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
