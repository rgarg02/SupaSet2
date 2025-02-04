import SwiftUI
import SceneKit


/// STEPS:
/// 1. All transformations must be applied in blender with the first frame being the rest position (important)
/// 2. Export the model as a .dae file
/// 3. Pretty print the dae file and use the xcode collada extension for the animation ids
/// 4. Center the model in xcode viewer
/// 5. Load the model and animation using SCNSceneSource
struct AnimationRigged: View {
    @State private var sceneView = SCNView()
    @State private var isPlaying = false
    @State private var modelNode: SCNNode?
    @State private var animation: CAAnimation?

    var body: some View {
        VStack {
            SceneKitContainer2(sceneView: $sceneView)
                .frame(height: 400)

            HStack {
                Button(isPlaying ? "Stop Animation" : "Play Animation") {
                    toggleAnimation()
                }
                .padding()
                .background(isPlaying ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .onAppear {
            loadModelAndAnimation()
        }
    }

    private func loadModelAndAnimation() {
        // Load the model
        guard let modelURL = Bundle.main.url(forResource: "Male_Full", withExtension: "scn"),
              let sceneSource = SCNSceneSource(url: modelURL, options: nil) else {
            fatalError("Failed to load the model file.")
        }

        // Load the root node
        let sceneS = try? SCNScene(url: sceneSource.url!, options: [.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])
        if let node = sceneS?.rootNode {
            modelNode = node
            let scene = SCNScene()
            scene.rootNode.addChildNode(node)

            // Configure the scene view
            sceneView.scene = scene
            sceneView.allowsCameraControl = true
            sceneView.autoenablesDefaultLighting = true
            sceneView.backgroundColor = UIColor.black

            // Adjust scale and position
//            node.scale = SCNVector3(1.0, 1.0, 1.0)
//            node.position = SCNVector3(0, -1, -2)

            
        }

        // Load the animation
        animation = sceneSource.entryWithIdentifier("Male_Full-1", withClass: CAAnimation.self)
        animation?.repeatCount = 1
        animation?.fadeInDuration = 1.0
        animation?.fadeOutDuration = 0.5
    }

    private func toggleAnimation() {
        guard let modelNode = modelNode, let animation = animation else { return }

        if isPlaying {
            modelNode.removeAllAnimations()
        } else {
            modelNode.addAnimation(animation, forKey: "Male_Full-1")
        }
        isPlaying.toggle()
    }
}

struct SceneKitContainer2: UIViewRepresentable {
    @Binding var sceneView: SCNView

    func makeUIView(context: Context) -> SCNView {
        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}

#Preview {
    AnimationRigged()
}
