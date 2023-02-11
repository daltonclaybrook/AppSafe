import Foundation
import PathKit
import ShellOut

/// This audit task ensures that the entitlements contain `get-task-allow: false`
struct GetTaskAllowTask: AuditTask {
	private static let regex = try! NSRegularExpression(
		pattern: #"\[Key\] get-task-allow\n\h*\[Value\]\n\h+\[Bool\] (true|false)\n"#
	)

	func performAudit(package: Path) async throws {
		let tmpDir = try TmpDir.tmpDir()
		let entitlements = tmpDir + "entitlements.txt"
		if entitlements.exists {
			try entitlements.delete()
		}

		try shellOut(to: "codesign", arguments: ["-dv", "--entitlements", entitlements.absolute().string, package.absolute().string])
		guard entitlements.exists else {
			throw GetTaskAllowTaskError.entitlementsFileNotCreated
		}

		let contents: String = try entitlements.read()
		guard let match = Self.regex.firstMatch(in: contents, range: NSRange(location: 0, length: contents.bridge().length)) else {
			throw GetTaskAllowTaskError.cantFindGetTaskAllowEntitlement
		}

		// The range of the first capture group, which should be "true" or "false"
		let valueRange = match.range(at: 1)
		guard valueRange.location != NSNotFound else {
			throw GetTaskAllowTaskError.invalidEntitlement
		}

		let valueString = contents.bridge().substring(with: valueRange)
		guard let entitlementValue = Bool(valueString) else {
			throw GetTaskAllowTaskError.invalidEntitlement
		}

		// This is the real test. This value must be false.
		if entitlementValue == true {
			throw GetTaskAllowTaskError.getTaskAllowIsTrue
		}
	}
}

enum GetTaskAllowTaskError: Error {
	case entitlementsFileNotCreated
	case cantFindGetTaskAllowEntitlement
	case invalidEntitlement
	case getTaskAllowIsTrue
}

extension GetTaskAllowTaskError: CustomStringConvertible {
	var description: String {
		switch self {
		case .entitlementsFileNotCreated:
			return "The entitlements file could not be exported from the build"
		case .cantFindGetTaskAllowEntitlement:
			return "The exported entitlements file does not contain the `get-task-allow` key"
		case .invalidEntitlement:
			return "The entitlements file could not be parsed"
		case .getTaskAllowIsTrue:
			return "The value for the `get-task-allow` entitlement is `true`. This must be `false` for App Store builds."
		}
	}
}
