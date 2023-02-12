import PathKit
import ShellOut

/// This audit task ensures there are not static frameworks bundled in the application
struct StaticFrameworksTask: AuditTask {
	let taskName = "Verify no static frameworks are embedded"

	func performAudit(package: Path) async throws {
		let frameworks = Path.glob("\(package.string)/Frameworks/*.framework")
		for framework in frameworks {
			guard framework.exists && framework.isDirectory else {
				continue
			}
			let name = framework.lastComponentWithoutExtension
			let binaryPath = framework + name
			guard binaryPath.exists else {
				continue
			}

			let fileResult = try shellOut(to: "file", arguments: [binaryPath.absolute().string])
			if fileResult.contains("current ar archive") {
				throw StaticFrameworkTaskError.binaryIsStaticLibrary(path: binaryPath.string)
			}
		}
	}
}

enum StaticFrameworkTaskError: Error {
	case binaryIsStaticLibrary(path: String)
}

extension StaticFrameworkTaskError: CustomStringConvertible {
	var description: String {
		switch self {
		case .binaryIsStaticLibrary(let path):
			return "Discovered a static library in the frameworks folder: \(path). You must not embed static libraries in your app bundle."
		}
	}
}
