//
//  Environment+CoreDataController.swift
//  PippinAdapters
//
//  Created by Andrew McKnight on 4/6/26.
//

import Pippin

public extension Environment {
    /// Convenience accessor that returns `model` cast to `CoreDataController`.
    /// Assigning a new value updates `model`. In DEBUG, asserts that any
    /// non-nil `model` is actually a `CoreDataController` — a nil result here
    /// means the app is misconfigured (wrong `Model` type).
    var coreDataController: CoreDataController? {
        get {
            #if DEBUG
            assert(model == nil || model is CoreDataController, "Environment.model is set but is not a CoreDataController")
            #endif
            return model as? CoreDataController
        }
        set { model = newValue }
    }
}
