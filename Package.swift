// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "AppSafe",
	platforms: [
		.macOS(.v12)
	],
    dependencies: [
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
		.package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1"),
		.package(url: "https://github.com/mxcl/Chalk.git", from: "0.5.0"),
		.package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0")
    ],
    targets: [
        .executableTarget(name: "AppSafe", dependencies: [
			.product(name: "ArgumentParser", package: "swift-argument-parser"),
			"PathKit",
			"Chalk",
			"ShellOut"
		]),
        .testTarget(name: "AppSafeTests", dependencies: ["AppSafe"]),
    ]
)
