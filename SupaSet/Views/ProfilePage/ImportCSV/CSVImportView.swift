//
//  CSVImportView.swift
//  SupaSet
//
//  Created by Rishi Garg on 4/14/25.
//

import SwiftUI
import SwiftData

struct CSVImportView: View {
    @State private var showImporter = false
    @State private var viewModel: CSVViewModel
    init(modelContext: ModelContext){
        viewModel = CSVViewModel(modelContext: modelContext)
    }
    var body: some View {
        VStack{
            Button {
                showImporter = true
            } label: {
                Text("Import Data")
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.commaSeparatedText]) { result in
            viewModel.handleFileImport(for: result)
        }
    }
}
