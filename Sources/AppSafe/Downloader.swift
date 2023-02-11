import Foundation
import PathKit

struct Downloader {
	func downloadToTemporaryFile(from url: String) async throws -> Path {
		let tmpDir = try TmpDir.tmpDir()
		guard let url = URL(string: url) else {
			throw AuditError.invalidURL(url)
		}

		print("🌐  Downloading build...")
		let (tempURL, response) = try await URLSession.shared.download(from: url)
		guard let response = response as? HTTPURLResponse else {
			throw AuditError.invalidHTTPResponseStatus(code: nil)
		}
		guard (200..<300).contains(response.statusCode) else {
			throw AuditError.invalidHTTPResponseStatus(code: response.statusCode)
		}

		let destination = tmpDir + url.lastPathComponent
		if destination.exists {
			try destination.delete()
		}
		try Path(tempURL.path).move(destination)
		return destination
	}
}
