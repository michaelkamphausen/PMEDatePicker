// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "PMEDatePicker",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "PMEDatePicker",
            targets: ["PMEDatePicker"]
        )
    ],
    targets: [
        .target(name: "PMEDatePicker")
    ]
)
