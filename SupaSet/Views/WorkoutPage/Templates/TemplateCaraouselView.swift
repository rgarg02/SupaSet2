//
//  TemplateCaraouselView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DragRelocateDelegate: DropDelegate {
    let item: Template
    @Binding var current: Template?

    func dropEntered(info: DropInfo) {
        // Safely unwrap the template we're dragging:
        guard let dragging = current, dragging != item else { return }

        let tempOrder = item.order
        withAnimation(.bouncy) {
            item.order = dragging.order
            dragging.order = tempOrder
        }
        
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        current = nil
        return true
    }
}

struct TemplateCarouselView: View {
    @Query(sort: \Template.order) var templates: [Template]
    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16),
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16)
    ]
    @State private var draggingTemplate: Template?
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                // Template Cards
                ForEach(templates) { template in
                    NavigationLink(destination: EditOrCreateTemplateView(template: template, isNew: false)) {
                        TemplateCard(template: template)
                            .onDrag {
                                // Start dragging the selected template:
//                                draggingTemplate = template
                                return NSItemProvider(object: String(template.id.uuidString) as NSString)
                            } preview: {
                                TemplateCard(template: template)
                                    .environment(exerciseViewModel)
                                    .onAppear{
                                        draggingTemplate = template
                                    }
                            }
                            .opacity(draggingTemplate?.id == template.id ? 0 : 1)
                    }
                    .onDrop(
                        of: [.text],
                        delegate: DragRelocateDelegate(
                            item: template,
                            current: $draggingTemplate
                        )
                    )
                }
                // Add Template Card
                NavigationLink(destination: createNewTemplateView()) {
                    AddTemplateCard()
                }
            }
            .padding()
        }
    }
    private func createNewTemplateView() -> some View {
        let newTemplate = Template(order: templates.count)
        return EditOrCreateTemplateView(template: newTemplate, isNew: true)
    }
    // You may not need this moveTemplate function anymore if your drop delegate
    // handles reordering by updating the `Template.order` directly.
    func moveTemplate(from source: Template, to destination: Template) {
        let tempOrder = source.order
        source.order = destination.order
        destination.order = tempOrder
    }
}

// Template Card View
struct TemplateCard: View {
    let template: Template
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Template Name
            Text(template.name)
                .font(.headline)
                .foregroundStyle(.primary)
            
            // Creation Date
            Text("Created: \(formattedDate(template.createdAt))")
                .font(.caption)
            
            // Exercises Preview
            VStack(alignment: .leading, spacing: 4) {
                ForEach(template.sortedExercises.prefix(4), id: \.id) { exercise in
                    HStack{
                        Text("\(exercise.sets.count)x")
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundStyle(Color.theme.accent)
                        Text(exerciseViewModel.getExerciseName(for: exercise.exerciseID))
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
                if template.exercises.count > 4 {
                    Text("+ \(template.exercises.count - 4) more")
                        .font(.subheadline)
                }
            }
        }
        .frame(height: 160)
        .foregroundStyle(Color.theme.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.theme.primarySecond)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Add Template Card View
struct AddTemplateCard: View {
    var body: some View {
        VStack {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 32))
            Text("Create Template")
                .font(.headline)
        }
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.theme.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .foregroundStyle(Color.theme.text)
    }
}

#Preview{
    let preview = PreviewContainer.preview
    NavigationStack{
        TemplateCarouselView()
            .modelContainer(preview.container)
            .environment(preview.viewModel)
    }
}
