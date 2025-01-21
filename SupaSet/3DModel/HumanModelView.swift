//
//  HumanModelView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/14/25.
//

import SwiftUI
import SceneKit

struct MuscleModelView: View {
    @State private var sceneView = SCNView()
    @State private var nodeName: String = ""
    @State private var showDetails: Bool = false
    @State private var isTapGestureEnabled: Bool = true
    @State private var movetoMuscle: String? = nil
    @State private var locationOfNode: Float? = nil
    
    // Sample muscle intensities (used for highlighting)
    @State private var primaryMuscles: [MuscleGroup] = [.biceps, .quadriceps]
    @State private var secondaryMuscles: [MuscleGroup] = [.triceps, .hamstrings]
    
    var body: some View {
        VStack {
            SceneKitContainer(
                sceneView: $sceneView,
                nodeName: $nodeName,
                showDetails: $showDetails,
                isTapGestureEnabled: isTapGestureEnabled,
                movetoMuscle: $movetoMuscle,
                locationOfNode: $locationOfNode
            )
            .frame(height: 500) // Set height for the 3D view
            
            if showDetails {
                Text("Selected Node: \(MuscleGroups.muscleForValue(nodeName)?.rawValue.capitalized ?? "Unknown")")
                    .font(.headline)
                    .padding()
                Button("Reset View") {
                    resetScene()
                }
                .padding()
            }
        }
        .onAppear {
            // Highlight muscles on first load
            highlightMuscleIntensity()
        }
    }
    func highlightMuscleIntensity(){
        DispatchQueue.main.async {
            sceneView.scene?.highlightMuscleIntensity(muscleIntensity: [:])
        }
    }
    func highlightMuscles() {
        DispatchQueue.main.async {
            sceneView.scene?.highlightTargetedMuscles(
                primaryMuscles: primaryMuscles,
                secondaryMuscles: secondaryMuscles
            )
        }
    }
    
    internal func resetScene() {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            sceneView.pointOfView?.position = SCNVector3(x: -0.119388437, y: -35.113367, z: -2.030692)
            sceneView.pointOfView?.orientation = SCNVector4(x: 0.70710677, y: 0.0, z: 0.0, w: 0.70710677)
            sceneView.scene?.highlightTargetedMuscles(primaryMuscles: [], secondaryMuscles: [])
            self.showDetails = false
            movetoMuscle = nil
            locationOfNode = nil
            SCNTransaction.commit()
    }
}

