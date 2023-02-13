import ArgumentParser
import Foundation
import PathKit

struct Audit: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		abstract: "A tool used to audit a build before submitting to the App Store"
	)

	@Option(name: [.short, .long], help: "The URL of an IPA file to download")
	var url: String?

	@Option(name: [.short, .long], help: "The file path of a local .app or .ipa file", completion: .file(extensions: ["ipa"]))
	var path: Path?

	/// The complete list of audit steps to perform
	private var auditTasks: [any AuditTask] {
		return [
			StaticFrameworksTask(),
			GetTaskAllowTask()
		]
	}

	func run() async throws {
		if let url, path == nil {
			let temporaryPath = try await Downloader().downloadToTemporaryFile(from: url)
			try await runAuditTasksOnBuild(at: temporaryPath)
		} else if let path, url == nil {
			try await runAuditTasksOnBuild(at: path)
		} else {
			throw AuditError.urlOrPath
		}
	}

	// MARK: - Private helpers

	private struct TaskResult: Equatable {
		enum Outcome: Equatable {
			case success
			case error(String)
		}

		let desription: String
		let outcome: Outcome
	}

	private func runAuditTasksOnBuild(at path: Path) async throws {
		let package = try Unarchive().unarchiveBuildIfNecessary(at: path)
		print("📝  Performing audit tasks...")

		let results = await withTaskGroup(of: TaskResult.self) { group in
			for task in auditTasks {
				group.addTask {
					let desription = task.briefDescription
					do {
						try await task.performAudit(package: package)
						print("\(desription): ✅")
						return TaskResult(desription: desription, outcome: .success)
					} catch let error {
						print("\(desription): ❌")
						return TaskResult(desription: desription, outcome: .error((error as CustomStringConvertible).description))
					}
				}
			}
			return await group.reduce(into: []) { $0.append($1) }
		}

		let errorStrings: [String] = results.compactMap { result in
			switch result.outcome {
			case .success:
				return nil
			case .error(let description):
				return description
			}
		}

		if errorStrings.isEmpty {
			print("✅  Audit complete!")
		} else {
			let allErrors = errorStrings.map { "  - \($0)" }.joined(separator: "\n")
			print("Errors:\n\(allErrors)")
			Darwin.exit(1)
		}
	}
}
