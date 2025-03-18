////
////  Shared.swift
////  SupaSet
////
////  Created by Rishi Garg on 1/21/25.
////
//
//// DraggableScrollContainer.swift
import SwiftUI

protocol ExerciseItem: Identifiable {
    var id: UUID { get }
    var order: Int { get set }
    var exerciseID: String { get }
}

extension WorkoutExercise: ExerciseItem {}

// Extension for TemplateExercise to conform to ExerciseItem
extension TemplateExercise: ExerciseItem {}

// Centralized state management for drag operations
class DragState: ObservableObject {
    @Published var isDragging = false
    @Published var selectedExercise: (any ExerciseItem)?
    @Published var selectedItemFrame: CGRect = .zero
    @Published var initialScrollOffset: CGRect = .zero
    @Published var currentOffset: CGSize = .zero
    @Published var scale: CGFloat = 1.0
    @Published var lastActiveScrollId: UUID?
    @Published var itemFrames: [UUID: CGRect] = [:]
    @Published var parentFrame: CGRect = .zero
    @Published var topRegion: CGRect = .zero
    @Published var bottomRegion: CGRect = .zero
    @Published var hapticFeedback = false
    @Published var isAutoScrolling = false
    
    // Add scroll direction enum
    var scrollDirection: ScrollDirection = .none
    private var autoScrollTimer: Timer?
    
    enum ScrollDirection {
        case up, down, none
    }
    
    @Published var scrollPosition: ScrollPosition = .init()
    @Published var currentScrollOffset: CGFloat = 0
    @Published var lastActiveScrollOffset: CGFloat = 0
    @Published var maximumScrollSize: CGFloat = 0
    
    func startDrag(item: any ExerciseItem, initialFrame: CGRect) {
        selectedExercise = item
        selectedItemFrame = initialFrame
        initialScrollOffset = initialFrame
        lastActiveScrollId = item.id
        
        withAnimation(.smooth(duration: 0.2)) {
            scale = 1.1
            isDragging = true
        }
    }
    
    func updateDrag(translation: CGSize, location: CGPoint) {
        // Calculate boundaries
        let minY = parentFrame.minY + 50
        let maxY = parentFrame.maxY - selectedItemFrame.height - 50
        
        // Calculate and clamp new position
        let newY = initialScrollOffset.minY + translation.height
        let clampedY = min(max(newY, minY), maxY)
        
        currentOffset = CGSize(width: 0, height: clampedY - initialScrollOffset.minY)
        
        // Update scroll direction based on location
        checkAndScroll(location)
    }
    
    func checkAndScroll(_ location: CGPoint) {
        let centeredLocation = CGPoint(x: parentFrame.midX, y: location.y)
        let topStatus = topRegion.contains(centeredLocation)
        let bottomStatus = bottomRegion.contains(centeredLocation)
        
        if topStatus || bottomStatus {
            if topStatus {
                scrollDirection = .up
            } else {
                scrollDirection = .down
            }
            
            if !isAutoScrolling {
                lastActiveScrollOffset = currentScrollOffset
                startAutoScroll()
            }
        } else {
            stopAutoScroll()
        }
    }
    
    private func startAutoScroll() {
        guard autoScrollTimer == nil else { return }
        isAutoScrolling = true
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let newOffset: CGFloat
            if self.scrollDirection == .up {
                newOffset = max(self.lastActiveScrollOffset - 15, 0)
            } else {
                newOffset = min(self.lastActiveScrollOffset + 15, self.maximumScrollSize)
            }
            
            self.lastActiveScrollOffset = newOffset
            withAnimation(.smooth(duration: 0.1)) {
                self.scrollPosition.scrollTo(y: newOffset)
            }
            
            if let currentId = self.lastActiveScrollId {
                if let fallingId = self.itemFrames.first(where: {
                    $0.value.contains(CGPoint(x: self.parentFrame.midX, y: newOffset + self.parentFrame.midY))
                })?.key,
                   fallingId != currentId {
                    self.lastActiveScrollId = fallingId
                    self.hapticFeedback.toggle()
                }
            }
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
        isAutoScrolling = false
    }
    
    func endDrag() {
        stopAutoScroll()
        
        withAnimation(.snappy(duration: 0.25), completionCriteria: .logicallyComplete) {
            if let selectedExercise = selectedExercise {
                itemFrames[selectedExercise.id] = selectedItemFrame
            }
            initialScrollOffset = selectedItemFrame
            scale = 1.0
            currentOffset = .zero
        } completion: {
            self.selectedExercise = nil
            self.initialScrollOffset = .zero
            self.selectedItemFrame = .zero
            self.lastActiveScrollId = nil
            
            withAnimation(.snappy) {
                self.isDragging = false
            }
        }
    }
}

// DraggableScrollContainer.swift - Simplified container
struct DraggableScrollContainer<Content: View, Item: ExerciseItem>: View {
    @Environment(ExerciseViewModel.self) var viewModel
    @EnvironmentObject var dragState: DragState
    // MARK: - Properties
    let content: () -> Content
    let items: [Item]
    
    // MARK: - Body
    var body: some View {
        VStack{
            ZStack(alignment: .topLeading) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        content()
                    }
                    .padding(.bottom, items.last.flatMap { (dragState.itemFrames[$0.id]?.height ?? 0)/2 } ?? 0)
                }
                .scrollIndicators(.hidden)
                .scrollPosition($dragState.scrollPosition)
                .contentMargins(.vertical, 30, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned)
                .onScrollGeometryChange(for: CGFloat.self, of: {
                    $0.contentOffset.y + $0.contentInsets.top
                }, action: { _, newValue in
                    dragState.currentScrollOffset = newValue
                })
                .onScrollGeometryChange(for: CGFloat.self, of: {
                    $0.contentSize.height - $0.containerSize.height
                }, action: { _, newValue in
                    dragState.maximumScrollSize = newValue
                })
                .padding(.horizontal)
                .overlay(alignment: .trailing) {
                    ProgressOverlay(items: items, dragState: dragState)
                }
                .measureFrame { dragState.parentFrame = $0 }
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 100)
                        .measureFrame { dragState.topRegion = $0 }
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 100)
                        .measureFrame { dragState.bottomRegion = $0 }
                }
                
                // Floating dragged item
                if let selectedItem = dragState.selectedExercise as? Item {
                    FloatingExerciseView(item: selectedItem, viewModel: viewModel)
                }
            }
            .sensoryFeedback(.impact, trigger: dragState.hapticFeedback)
        }
    }
}

// Helper struct for the progress indicator
struct ProgressOverlay<Item: ExerciseItem>: View {
    let items: [Item]
    @ObservedObject var dragState: DragState
    var body: some View {
        if dragState.isDragging {
            if let selectedItem = dragState.selectedExercise {
                WorkoutProgressDots(
                    totalExercises: items.count,
                    currentExerciseIndex: items.firstIndex(where: { $0.id == selectedItem.id }) ?? 0
                )
                .padding(.trailing, 3)
            }
        }
    }
}
// A modifier to measure frame in a cleaner way
struct FrameMeasurer: ViewModifier {
    var onMeasured: (CGRect) -> Void
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            onMeasured(geometry.frame(in: .global))
                        }
                        .onChange(of: geometry.frame(in: .global)) { _, newRect in
                            onMeasured(newRect)
                        }
                }
            )
    }
}

extension View {
    func measureFrame(action: @escaping (CGRect) -> Void) -> some View {
        modifier(FrameMeasurer(onMeasured: action))
    }
}
// Helper struct for the floating exercise during drag
struct FloatingExerciseView<Item: ExerciseItem>: View {
    let item: Item
    let viewModel: ExerciseViewModel
    @EnvironmentObject var dragState: DragState
    
    var body: some View {
        let adjustedOffset = CGRect(
            x: dragState.initialScrollOffset.minX,
            y: dragState.initialScrollOffset.minY - dragState.parentFrame.minY,
            width: dragState.initialScrollOffset.width,
            height: dragState.initialScrollOffset.height
        )
        
        HStack {
            Text(viewModel.getExerciseName(for: item.exerciseID))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.theme.text)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .frame(
            width: dragState.itemFrames[item.id]?.width ?? .zero,
            height: dragState.itemFrames[item.id]?.height ?? .zero
        )
        .scaleEffect(dragState.scale)
        .offset(x: adjustedOffset.minX, y: adjustedOffset.minY)
        .offset(dragState.currentOffset)
        .ignoresSafeArea()
        .transition(.identity)
    }
}
