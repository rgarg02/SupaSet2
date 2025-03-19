//
//  TemplateCaraouselView.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/21/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TemplateCarouselView: View {
    @Query(sort: \Template.order) var templates: [Template]
    private let columns = [
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16),
        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 16)
    ]
    @State private var draggingTemplate: Template?
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    var body: some View {
        VStack(alignment: .leading) {
            TemplateTitle()
            ScrollView {
                LazyVGrid(columns: columns,
                          spacing: 16) {
                    // Template Cards
                    ForEach(templates) { template in
                        NavigationLink(destination:
                                        EditOrCreateTemplateView(template: template, isNew: false)
                                       
                        ) {
                            ExistingTemplateCard(template: template)
                        }
                        
                    }
                    // Add Template Card
                    NavigationLink(destination: createNewTemplateView()
                        ) {
                            AddTemplateCard()
                        }
                }
                          .padding()
            }
        }
        .onDrop(of: [UTType.text], delegate: DropOutsideDelegate(current: $draggingTemplate))
        .onChange(of: templates.count) { oldValue, newValue in
            for (index,template) in templates.enumerated() {
                template.order = index
            }
        }
    }
    
    @ViewBuilder
    func TemplateTitle() -> some View {
         Text("Templates")
            .font(.title)
            .fontWeight(.bold)
            .padding(.horizontal)
    }
    @ViewBuilder
    func ExistingTemplateCard(template: Template) -> some View {
        TemplateCard(template: template)
            .onDrag {
                return NSItemProvider(object: String(template.id.uuidString) as NSString)
            } preview: {
                TemplateCard(template: template)
                    .environment(exerciseViewModel)
                    .onAppear{
                        draggingTemplate = template
                    }
                    .cornerRadius(12)
            }
            .opacity(draggingTemplate?.id == template.id ? 0 : 1)
            .onDrop(
                of: [.text],
                delegate: DragRelocateDelegate(
                    item: template,
                    current: $draggingTemplate
                )
            )
    }
    private func createNewTemplateView() -> some View {
        return EditOrCreateTemplateView(isNew: true)
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
