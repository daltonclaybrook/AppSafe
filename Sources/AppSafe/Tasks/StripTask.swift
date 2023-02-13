import PathKit
import ShellOut

struct StripTask: AuditTask {
	let briefDescription = "Ensure that symbols have been stripped from the binary"

	func performAudit(package: Path) async throws {
		let binaryName = package.lastComponentWithoutExtension
		let binaryPath = package + binaryName

		let tmpDir = try TmpDir.tmpDir()
		let strippedPath = tmpDir + "\(binaryName)-stripped"
		if strippedPath.exists {
			try strippedPath.delete()
		}

		try shellOut(to: "strip", arguments: [
			"-rSTx", binaryPath.absolute().string,
			"-o", strippedPath.absolute().string
		])

		// Take the hashes of both files. If the binary has already been stripped
		// sufficiently, the files and hashes will be identical.
		let binaryHash = try FileHash(path: binaryPath).hashOfFile()
		let strippedHash = try FileHash(path: strippedPath).hashOfFile()
		if binaryHash != strippedHash {
			throw StripTaskError.binaryFileIsNotSufficientlyStripped
		}
	}
}

enum StripTaskError: Error {
	case binaryFileIsNotSufficientlyStripped
}

extension StripTaskError: CustomStringConvertible {
	var description: String {
		switch self {
		case .binaryFileIsNotSufficientlyStripped:
			return "Symbols are not sufficiently stripped from the binary. Ensure that you have run `strip -rSTx` on your release binary and embedded framework binaries."
		}
	}
}
