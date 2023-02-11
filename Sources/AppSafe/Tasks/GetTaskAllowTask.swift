import PathKit

/// This audit task ensures that the entitlements contain `get-task-allow: false`
struct GetTaskAllowTask: AuditTask {
	func performAudit(package: Path) async throws {
		// To-do: implement
	}
}
