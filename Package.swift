// swift-tools-version: 5.9
//
//  Package.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "KitoFormatting",
    platforms: [.iOS(.v17)],
    products: [.library(name: "KitoFormatting", targets: ["KitoFormatting"])],
    targets: [
        .target(name: "KitoFormatting"),
        .testTarget(name: "KitoFormattingTests", dependencies: ["KitoFormatting"]),
    ]
)
