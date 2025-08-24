import Foundation

/// An overlay mapping between full module names and shortened, by hashing, file names.
/// 
/// This overlay is an output of symbol graph generation from the Swift compiler whem shortened
/// file names are requested. The shortened file names are computed by hashing the actual
/// "module@extended-module" file names.
public struct ModuleOverlay: Codable, Equatable {
    public typealias GraphModuleName = String
    public typealias RealFileName = String

    public let modules: [GraphModuleName: RealFileName]

    private lazy var modulesByFile: [RealFileName: GraphModuleName] = {
        Dictionary(uniqueKeysWithValues: modules.map { ($0.value, $0.key) })
    }()

    public init(modules: [String: String]) {
        self.modules = modules
    }
}

extension ModuleOverlay {
    public mutating func moduleFileName(for realURL: URL) -> URL {
        let variants = [
            realURL.lastPathComponent, 
            realURL.deletingPathExtension().lastPathComponent
        ]
        let map = modulesByFile
        return variants.lazy.compactMap { map[$0] }.first.map {
            realURL.deletingLastPathComponent().appendingPathComponent($0)
        } ?? realURL
    }
}
