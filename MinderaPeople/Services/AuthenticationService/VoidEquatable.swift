import Foundation

public struct VoidEquatable: Equatable {}

extension VoidEquatable {
    static func stub() -> VoidEquatable {.init() }
}
