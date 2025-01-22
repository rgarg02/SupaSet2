//
//  Shared.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

// DraggableScrollContainer.swift
import SwiftUI

struct DraggableScrollContainer<Content: View, Item: ExerciseItem>: View {
    @Environment(ExerciseViewModel.self) var viewModel
    // MARK: - Properties
    let content: Content
    let items: [Item]
    @Binding var selectedItem: Item?
    @Binding var selectedItemScale: CGFloat
    @Binding var selectedItemFrame: CGRect
    @Binding var offset: CGSize
    @Binding var hapticsTrigger: Bool
    @Binding var initialScrollOffset: CGRect
    @Binding var scrolledItem: Item.ID?
    @Binding var lastActiveScrollId: Item.ID?
    @Binding var dragging: Bool
    @Binding var parentFrame: CGRect
    @Binding var itemFrames: [Item.ID: CGRect]
    @Binding var topRegion: CGRect
    @Binding var bottomRegion: CGRect
    let onScroll: (CGPoint) -> Void
    let onSwap: (CGPoint) -> Void
    
    
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                    content
                        .padding(.bottom, items.last.flatMap { (itemFrames[$0.id]?.height ?? 0)/2 } ?? 0)
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $scrolledItem) // Add anchor parameter
            .contentMargins(.vertical, 30)
            .scrollTargetBehavior(.viewAligned)
            .padding(.horizontal, 20)
            .overlay(alignment: .trailing) {
                if dragging {
                    if let selectedItem {
                        WorkoutProgressDots(totalExercises: items.count, currentExerciseIndex: items.firstIndex(where: { $0.id == selectedItem.id }) ?? 0)
                            .padding(.trailing, 10)
                    }
                    
                }else{
                    WorkoutProgressDots(totalExercises: items.count, currentExerciseIndex: items.firstIndex(where: {$0.id == scrolledItem}) ?? 0)
                        .padding(.trailing, 10)
                }
            }
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .global)
            } action: { newValue in
                // Only update if the frame actually changed significantly
                if abs(parentFrame.minY - newValue.minY) > 1 {
                    parentFrame = newValue
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .global)
                    } action: { newValue in
                        topRegion = newValue
                    }
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                    .onGeometryChange(for: CGRect.self) {
                        $0.frame(in: .global)
                    } action: { newValue in
                        bottomRegion = newValue
                    }
            }
            .overlay(alignment: .topLeading) {
                let adjustedInitialOffset = CGRect(
                                    x: initialScrollOffset.minX,
                                    y: initialScrollOffset.minY - parentFrame.minY,
                                    width: initialScrollOffset.width,
                                    height: initialScrollOffset.height
                                )
                if let selectedItem {
                    HStack {
                        Text(viewModel.getExerciseName(for: selectedItem.exerciseID))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.theme.text)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .modifier(ExerciseCardStyle())
                    .frame(width: itemFrames[selectedItem.id]?.width ?? .zero, height: itemFrames[selectedItem.id]?.height ?? .zero)
                    .scaleEffect(selectedItemScale)
                    .offset(x: adjustedInitialOffset.minX,
                            y: adjustedInitialOffset.minY)
                    .offset(offset)
                    .ignoresSafeArea()
                    .transition(.identity)
                }
            }
        }
        .sensoryFeedback(.impact, trigger: hapticsTrigger)
    }
    
}
// Protocol to define common requirements for exercise types
protocol ExerciseItem: Identifiable {
    var id: UUID { get }
    var order: Int { get set }
    var exerciseID: String { get }
}

// Base view modifier for common card styling
struct ExerciseCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.theme.background)
                    .shadow(
                        color: Color.theme.primary.opacity(0.5),
                        radius: 5,
                        x: 0,
                        y: 2
                    )
                    .padding(8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.theme.accent, lineWidth: 1)
                    .padding(8)
            )
    }
}

struct DraggableGestureHandler<T: ExerciseItem> {
    let item: T
    @Binding var selectedExercise: T?
    @Binding var selectedExerciseScale: CGFloat
    @Binding var selectedExerciseFrame: CGRect
    @Binding var offset: CGSize
    @Binding var hapticsTrigger: Bool
    @Binding var initialScrollOffset: CGRect
    @Binding var lastActiveScrollId: UUID?
    @Binding var dragging: Bool
    @Binding var parentBounds: CGRect
    @Binding var exerciseFrames: [UUID: CGRect]
    let onScroll: (CGPoint) -> Void
    let onSwap: (CGPoint) -> Void
    
    var gesture: some Gesture {
        LongPressGesture(minimumDuration: 0.25)
            .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
            .onChanged { value in
                switch value {
                case .second(let status, let value):
                    if status {
                        if selectedExercise == nil {
                            selectedExercise = item
                            selectedExerciseFrame = exerciseFrames[item.id] ?? .zero
                            initialScrollOffset = selectedExerciseFrame
                            initialScrollOffset = selectedExerciseFrame
                            lastActiveScrollId = item.id
                            hapticsTrigger.toggle()
                            
                            withAnimation(.smooth(duration: 0.2, extraBounce: 0)) {
                                selectedExerciseScale = 1.1
                                dragging = true
                            }
                        }
                        
                        if let value {
                            // Calculate the new Y position
                            let newY = initialScrollOffset.minY + value.translation.height
                            
                            // Get the available vertical space
                            let minY = parentBounds.minY + 50 // Add some padding from top
                            let maxY = parentBounds.maxY - selectedExerciseFrame.height - 50 // Subtract height and padding
                            
                            // Clamp the Y position
                            let clampedY = min(max(newY, minY), maxY)
                            
                            // Calculate the clamped offset
                            let clampedOffset = CGSize(
                                width: 0,
                                height: clampedY - initialScrollOffset.minY
                            )
                            
                            offset = clampedOffset
                            let location = value.location
                            onScroll(location)
                            onSwap(location)
                        }
                    }
                default: ()
                }
            }
            .onEnded { _ in
                withAnimation(.snappy(duration: 0.25, extraBounce: 0),
                              completionCriteria: .logicallyComplete) {
                    if let selectedExercise = selectedExercise {
                        exerciseFrames[selectedExercise.id] = selectedExerciseFrame
                    }
                    initialScrollOffset = selectedExerciseFrame
                    selectedExerciseScale = 1.0
                    offset = .zero
                } completion: {
                    selectedExercise = nil
                    initialScrollOffset = .zero
                    selectedExerciseFrame = .zero
                    lastActiveScrollId = nil
                    withAnimation(.snappy) {
                        dragging = false
                    }
                }
            }
    }
}
// Extension for WorkoutExercise to conform to ExerciseItem
extension WorkoutExercise: ExerciseItem {}

// Extension for TemplateExercise to conform to ExerciseItem
extension TemplateExercise: ExerciseItem {}
