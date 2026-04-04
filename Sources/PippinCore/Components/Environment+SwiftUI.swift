#if canImport(SwiftUI)
import SwiftUI

private struct PippinEnvironmentKey: EnvironmentKey {
    static let defaultValue: Environment = Environment()
}

public extension EnvironmentValues {
    var pippinEnvironment: Environment {
        get { self[PippinEnvironmentKey.self] }
        set { self[PippinEnvironmentKey.self] = newValue }
    }
}
#endif
