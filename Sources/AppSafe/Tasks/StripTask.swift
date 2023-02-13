import PathKit

struct StipTask: AuditTask {
	let briefDescription = "Ensure that symbols have been stripped from the binary"

	func performAudit(package: Path) async throws {
		//
	}
}
