import ArgumentParser

@main
struct AppSafe: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "appsafe",
		abstract: "A tool used the keep your app safe",
		version: "0.1.0",
		subcommands: [
			Audit.self
		]
	)
}
