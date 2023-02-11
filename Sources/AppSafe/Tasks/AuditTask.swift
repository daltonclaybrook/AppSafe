import PathKit

/// Types that conform to this protocol can perform a specific kind of audit of a build
protocol AuditTask {
	func performAudit(package: Path) async throws
}
