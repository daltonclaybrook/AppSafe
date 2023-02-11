import Foundation
import PathKit

struct TmpDir {
	static func tmpDir() throws -> Path {
		guard let tmpDirString = ProcessInfo.processInfo.environment["TMPDIR"] else {
			throw AuditError.unableToDetermineTmpDir
		}
		return Path(tmpDirString)
	}
}
