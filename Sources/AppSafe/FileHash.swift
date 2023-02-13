import CryptoKit
import Foundation
import PathKit

struct FileHash {
	private static let bufferSize = 1024
	let path: Path

	func hashOfFile() throws -> Data {
		var digest = Insecure.MD5()
		guard let fileHandle = FileHandle(forReadingAtPath: path.absolute().string) else {
			throw FileHashError.failedToMakeFileHandle
		}
		while let data = try fileHandle.read(upToCount: Self.bufferSize) {
			digest.update(data: data)
		}
		return Data(digest.finalize())
	}
}

enum FileHashError: Error {
	case failedToMakeFileHandle
}

extension FileHashError: CustomStringConvertible {
	var description: String {
		switch self {
		case .failedToMakeFileHandle:
			return "Failed to calculate hash of file"
		}
	}
}
