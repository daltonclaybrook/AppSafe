import PathKit

/// Types that conform to this protocol can perform a specific kind of audit of a build
protocol AuditTask {
	/// A brief, one-line description of the task
	var briefDescription: String { get }
	/// Perform the audit task
	func performAudit(package: Path) async throws
}
