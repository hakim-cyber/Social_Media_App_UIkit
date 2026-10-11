import Foundation

enum TestFixture {
    static func data(
        named name: String,
        extension fileExtension: String = "json",
        subdirectory: String? = nil
    ) throws -> Data {
        let bundle = Bundle(for: BundleToken.self)
        let url = bundle.url(forResource: name, withExtension: fileExtension, subdirectory: subdirectory)
            ?? bundle.url(forResource: name, withExtension: fileExtension)

        guard let url else {
            throw FixtureError.missingResource(name: name, fileExtension: fileExtension)
        }

        return try Data(contentsOf: url)
    }
}

private final class BundleToken {}

private enum FixtureError: LocalizedError {
    case missingResource(name: String, fileExtension: String)

    var errorDescription: String? {
        switch self {
        case let .missingResource(name, fileExtension):
            return "Missing test fixture: \(name).\(fileExtension)"
        }
    }
}
