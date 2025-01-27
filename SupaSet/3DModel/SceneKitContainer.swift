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
    @Binding var sceneView: SCNView
    @State private var isLoading = true // Flag for loading state
    @Binding var nodeName: String
    @Binding var showDetails: Bool
    let isTapGestureEnabled : Bool
    @Binding var movetoMuscle : String?
    @Binding var locationOfNode : Float?
    func makeUIView(context: Context) -> SCNView {
        let scene = setupScene()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .clear
        // Add modern visual effects
        sceneView.layer.cornerRadius = 8
        sceneView.layer.masksToBounds = true
        sceneView.layer.borderWidth = 1
        sceneView.defaultCameraController.maximumVerticalAngle = 0.001
        // Add ambient occlusion for better depth
        // Optimize rendering
        sceneView.antialiasingMode = .multisampling2X  // Reduced from 4X
        sceneView.preferredFramesPerSecond = 30        // Limit frame rate
        sceneView.isJitteringEnabled = false           // Disable jittering
        sceneView.rendersContinuously = false          // Only render when needed
        
        // Optimize scene graph
        scene.rootNode.flattenedClone()                // Optimize node hierarchy
        
        // Add gestures
        addGestures(to: sceneView, context: context)
        return sceneView
    }
    private func addGestures(to view: SCNView, context: Context) {
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        context.coordinator.tapGesture = tapGesture  // Store the gesture in the coordinator
    }
    func updateUIView(_ uiView: SCNView, context: Context) {
        context.coordinator.tapGesture?.isEnabled = isTapGestureEnabled
        if let movetoMuscle, let locationOfNode{
            DispatchQueue.main.async {
                sceneView.scene?.rootNode.enumerateHierarchy({ node, _ in
                    if node.name == movetoMuscle {
                        moveCamera(to: node, location: locationOfNode)
                    }
                })
            }
        }
    }
    
    private func setupScene() -> SCNScene {
        guard let scene = SCNScene(named: "Male_Full.dae",
                                   inDirectory: "",
                                   options: [
                                    .createNormalsIfAbsent: true,
                                    .flattenScene: true,
                                    .checkConsistency: false,
                                    .preserveOriginalTopology: false,
                                    .animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay
                                   ]) else {
            fatalError("Failed to find model file.")
        }
        
        // Optimize lighting
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 100
        scene.rootNode.addChildNode(ambientLight)
        
        // Cache materials
        scene.rootNode.enumerateChildNodes { node, _ in
            node.geometry?.materials.forEach { material in
                material.lightingModel = .phong  // Use simpler lighting model
                material.isDoubleSided = false   // Disable double-sided rendering
            }
                }
        return scene
    }
    func resetCameraToDefaultPosition() {
        sceneView.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 0)
        sceneView.pointOfView?.orientation = SCNVector4(x: 0, y: 0, z: 0, w: 1)
        
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
            let p = gestureRecognize.location(in: parent.sceneView)
            let hitResults = parent.sceneView.hitTest(p, options: [:])
            
            if let result = hitResults.first, let nodeName = result.node.name, let muscleGroup = MuscleGroups.muscleMappings.first(where: { $1.contains(nodeName) })?.key {
                DispatchQueue.main.async {
                    self.parent.nodeName = nodeName
                    self.parent.showDetails = true
                }
                
                // Call the new function to move the camera
                //                parent.moveCamera(to: result.node, location: Float(MuscleGroups.getLocation(of: muscleGroup)))
                
                // Highlight targeted muscles
                parent.sceneView.scene?.highlightTargetedMuscles(primaryMuscles: [muscleGroup], secondaryMuscles: [])
            }
        }
    }
    func moveCamera(to node: SCNNode, location: Float) {
        let fov = sceneView.pointOfView?.camera?.fieldOfView ?? 60.0
        let (minBound, maxBound) = node.boundingBox
        let nodeSize = SCNVector3(
            x: abs(maxBound.x - minBound.x),
            y: abs(maxBound.y - minBound.y),
            z: abs(maxBound.z - minBound.z)
        )
        let largestDimension = max(nodeSize.x, nodeSize.y, nodeSize.z)
        let idealDistance = Double(largestDimension) / (2 * tan(Double(fov) * .pi / 360))
        
        // Prepare the camera position with animation
        let cameraPosition = SCNVector3(
            x: node.worldPosition.x,
            y: node.worldPosition.y + Float(idealDistance) * location,
            z: node.worldPosition.z
        )
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        sceneView.pointOfView?.position = cameraPosition
        sceneView.pointOfView?.orientation = SCNVector4(x: 0.70710677, y: 0.0, z: 0.0, w: 0.70710677)
        sceneView.pointOfView?.look(at: node.worldPosition)
        SCNTransaction.commit()
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

// Usage in SwiftUI
struct ModernSceneKitView: View {
    @State private var sceneView = SCNView()
    
    var body: some View {
        ZStack {
            // SceneKit container
            SceneKitContainer(
                sceneView: $sceneView,
                nodeName: .constant(""),
                showDetails: .constant(false),
                isTapGestureEnabled: true,
                movetoMuscle: .constant(nil),
                locationOfNode: .constant(nil)
            )
            //            .clipShape(RoundedRectangle(cornerRadius: 8))
            //            .shadow(
            //                color: Color.black.opacity(0.2),
            //                radius: 10,
            //                x: 0,
            //                y: 5
            //            )
        }
    }
}
#Preview {
    @Previewable @State var sceneView = SCNView()
    ModernSceneKitView()
}
