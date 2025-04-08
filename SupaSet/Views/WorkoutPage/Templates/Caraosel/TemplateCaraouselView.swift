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
    @State private var collapsed = false
    @Environment(ExerciseViewModel.self) var exerciseViewModel
    var body: some View {
        ScrollView {
            VStack {
                TemplateCaraouselTopControls()
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ForEach(templates) { template in
                        NavigationLink(destination: EditOrCreateTemplateView(template: template, isNew: false)) {
                            ExistingTemplateCard(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .animation(.default, value: collapsed)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onDrop(of: [UTType.text], delegate: DropOutsideDelegate(current: $draggingTemplate, collapsed: $collapsed))
        .onChange(of: templates.count) { oldValue, newValue in
            for (index,template) in templates.enumerated() {
                template.order = index
            }
        }
    }
    @ViewBuilder
    func TemplateCaraouselTopControls() -> some View {
        HStack{
            TemplateTitle()
            Spacer()
            Button(action: {
                collapsed.toggle()
            }) {
                Image(systemName: collapsed ? "rectangle.grid.1x2" : "rectangle.portrait" )
                    .font(.caption.bold())
                    .foregroundColor(.text)
                    .contentTransition(.symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating))
            }
            .padding(5)
            .background(ZStack{
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.text.opacity(0.3), lineWidth: 1)
            })
            NavigationLink(destination: createNewTemplateView()) {
                AddTemplateButton()
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 16)
    }
    @ViewBuilder
    func TemplateTitle() -> some View {
        Text("Templates")
            .font(.title.bold())
    }
    @ViewBuilder
    func ExistingTemplateCard(template: Template) -> some View {
        TemplateCard(template: template, collapsed: collapsed)
            .onDrag {
                return NSItemProvider(object: String(template.id.uuidString) as NSString)
            } preview: {
                TemplateCard(template: template, collapsed: true)
                    .environment(exerciseViewModel)
                    .onAppear{
                        draggingTemplate = template
                        collapsed = true
                    }
                    .cornerRadius(12)
            }
            .opacity(draggingTemplate?.id == template.id ? 0 : 1)
            .onDrop(
                of: [.text],
                delegate: DragRelocateDelegate(
                    item: template,
                    current: $draggingTemplate,
                    collapsed: $collapsed
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
