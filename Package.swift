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
    dependencies: [
        .package(url: "https://github.com/WykSofts-Inc/KitoCore.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "KitoFormatting", dependencies: [.product(name: "KitoCore", package: "KitoCore")]),
        .testTarget(name: "KitoFormattingTests", dependencies: ["KitoFormatting"]),
    ]
)
