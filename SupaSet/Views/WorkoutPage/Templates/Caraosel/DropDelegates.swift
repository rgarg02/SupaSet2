//
//  DropDelegates.swift
//  SupaSet
//
//  Created by Rishi Garg on 1/25/25.
//

import SwiftUI

struct DropOutsideDelegate: DropDelegate {
    @Binding var current: Template?
        
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        return true
    }
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
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
