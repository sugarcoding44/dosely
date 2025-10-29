// swift-tools-version: 5.9
// Package file for Swift Package Manager dependencies

import PackageDescription

let package = Package(
    name: "Dosely",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Dosely",
            targets: ["Dosely"]),
    ],
    dependencies: [
        // Supabase Swift SDK
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "Dosely",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
            ]),
    ]
)
