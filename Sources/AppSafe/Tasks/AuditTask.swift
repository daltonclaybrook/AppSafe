import PathKit

/// Types that conform to this protocol can perform a specific kind of audit of a build
protocol AuditTask {
	/// The name of the task that will be performed
	var taskName: String { get }
	/// Perform the audit task
	func performAudit(package: Path) async throws
}
