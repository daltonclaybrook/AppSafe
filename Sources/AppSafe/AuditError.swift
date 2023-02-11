enum AuditError: Error {
	case unableToDetermineTmpDir
	case urlOrPath
	case invalidURL(String)
	case fileDoesNotExist(path: String)
	case invalidHTTPResponseStatus(code: Int?)
	case invalidIPAOrAppPackage
	case cantFindUnzippedPackage
	case oneOrMoreTasksFailed
}

extension AuditError: CustomStringConvertible {
	var description: String {
		switch self {
		case .unableToDetermineTmpDir:
			return "Unable to determine your temporary directory. Make sure the TMPDIR environment variable is set."
		case .urlOrPath:
			return "You must specify a URL with `--url` or a file path with `--path`, but not both."
		case .invalidURL(let url):
			return "The provided URL is invalid: \(url)"
		case .fileDoesNotExist(let path):
			return "File does not exist at path: \(path)"
		case .invalidHTTPResponseStatus(let code):
			let codeString = code.map { " (code: \($0)" } ?? ""
			return "Invalid HTTP response\(codeString)"
		case .invalidIPAOrAppPackage:
			return "The provided file must either be an .app package or an .ipa"
		case .cantFindUnzippedPackage:
			return "Failed to locate package after unzipping the IPA"
		case .oneOrMoreTasksFailed:
			return "Audit failed. One or more tasks resulted in an error."
		}
	}
}
