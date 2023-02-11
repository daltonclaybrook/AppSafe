import PathKit
import ShellOut

struct Unarchive {
	/// If the build at the provided path is an archive, unarchive it and move it to a temporary location.
	/// Otherwise, just return the provided path.
	func unarchiveBuildIfNecessary(at path: Path) throws -> Path {
		guard path.exists else {
			throw AuditError.fileDoesNotExist(path: path.string)
		}
		if path.extension == "app" && path.isDirectory {
			/// This file has already been unarchived
			return path
		}
		guard path.extension == "ipa" && path.isFile else {
			throw AuditError.invalidIPAOrAppPackage
		}

		let tmpDir = try TmpDir.tmpDir()
		let destination = tmpDir + "Audit"
		if destination.exists {
			try destination.delete()
		}

		print("📦  Unarchiving IPA at path: \(path.string)")
		try shellOut(to: "unzip", arguments: [path.string, "-d", destination.string])
		guard let package = Path.glob("\(destination.string)/Payload/*.app").first else {
			throw AuditError.cantFindUnzippedPackage
		}

		return package
	}
}
