import ArgumentParser
import PathKit

extension Path: ExpressibleByArgument {
	public init?(argument: String) {
		self = Path(argument)
	}
}
