//
//  DraggableModel.swift
//  SupaSet
//
//  Created by Rishi Garg on 11/24/24.
//
import SwiftUI
public struct Point: Codable {
    public var x: Double
    public var y: Double
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public init(_ cgPoint: CGPoint) {
        self.x = cgPoint.x
        self.y = cgPoint.y
    }
    
    public func asCGPoint() -> CGPoint {
        CGPoint(x: x, y: y)
    }
}

public struct Size: Codable {
    public var width: Double
    public var height: Double
    
    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    public init(_ cgSize: CGSize) {
        self.width = cgSize.width
        self.height = cgSize.height
    }
    
    public func asCGSize() -> CGSize {
        CGSize(width: width, height: height)
    }
}

public struct Frame: Codable {
    public var origin: Point
    public var size: Size
    
    public init(
        x: Double,
        y: Double,
        width: Double,
        height: Double
    ) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
    
    public init(_ cgRect: CGRect) {
        self.origin = Point(cgRect.origin)
        self.size = Size(cgRect.size)
    }
    
    public func asCGRect() -> CGRect {
        CGRect(
            origin: origin.asCGPoint(),
            size: size.asCGSize())
    }
}
