import PackagePlugin
import Foundation

@main
struct Script: CommandPlugin {
	func performCommand(context: PluginContext, arguments: [String]) async throws {
		let executableTargets = context.package.targets(ofType: SwiftSourceModuleTarget.self).filter { $0.kind == .executable }
		guard executableTargets.count == 1 else {
			throw InstallError.invalidNumberOfExecutableTargets(executableTargets.count)
		}

		let target = executableTargets[0]
		let packageDirectory = context.package.directory.string
		let contents = generateInstallScriptContents(targetName: target.name, packagePath: packageDirectory)

		let destinationPath = "\(packageDirectory)/script.sh"
		if FileManager.default.fileExists(atPath: destinationPath) {
			try FileManager.default.removeItem(atPath: destinationPath)
		}

		// Write the file to the destination
		try contents.write(toFile: destinationPath, atomically: true, encoding: .utf8)

		// Make the file executable
		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/bin/chmod")
		process.arguments = ["+x", destinationPath]
		try process.run()
		process.waitUntilExit()

		print("Script written to file: \(destinationPath)")
		print("You can install it to your /usr/local/bin folder by running:")
		print("> sudo cp \(destinationPath) /usr/local/bin/\(target.name.lowercased())")
	}
}

private func generateInstallScriptContents(targetName: String, packagePath: String) -> String {
"""
#!/bin/bash

APP_NAME='\(targetName)'
PACKAGE_DIR='\(packagePath)'
LOG_FILE="$PACKAGE_DIR/.build.log"

echo 'Building...'
swift build --package-path "$PACKAGE_DIR" -c release > "$LOG_FILE" 2>&1
if [[ $? != 0 ]]; then
	cat "$LOG_FILE"
	exit $?
fi

swift run --skip-build --package-path "$PACKAGE_DIR" -c release "$APP_NAME" "$@"

"""
}

enum InstallError: Error {
	case invalidNumberOfExecutableTargets(Int)
}

extension InstallError: CustomStringConvertible {
	var description: String {
		switch self {
		case .invalidNumberOfExecutableTargets(let count):
			return "Expected exactly one executable target. Found \(count)."
		}
	}
}
