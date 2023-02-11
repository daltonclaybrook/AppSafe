import ArgumentParser
import Foundation
import PathKit

struct Audit: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "A tool used to audit a build before submitting to the App Store"
	)

	@Option(name: [.short, .long], help: "The URL of an IPA file to download")
	var url: String?

	@Option(name: [.short, .long], help: "The file path of a local .app or .ipa file")
	var path: String?

	private var tmpDir: Path? {
		guard let tmpDirString = ProcessInfo.processInfo.environment["TMPDIR"] else { return nil }
		return Path(tmpDirString)
	}

	func run() async throws {
		if let url, path == nil {
			let temporaryPath = try await Downloader().downloadToTemporaryFile(from: url)
			try await processBuild(at: temporaryPath)
		} else if let path, url == nil {
			try await processBuild(at: Path(path))
		} else {
			throw AuditError.urlOrPath
		}
	}

	// MARK: - Private helpers

	private func processBuild(at path: Path) async throws {
		guard path.exists else {
			throw AuditError.fileDoesNotExist(path: path.string)
		}
	}
}
