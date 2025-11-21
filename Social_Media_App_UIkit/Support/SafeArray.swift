//
//  SafeArray.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 11/22/25.
//

import SwiftUI
extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension MutableCollection {
    subscript(safe index: Index) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }

        set(newValue) {
            if let newValue = newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
    }
}
extension Binding where Value: MutableCollection, Value.Index: Comparable {
    subscript(safe index: Value.Index) -> Binding<Value.Element?> {
        Binding<Value.Element?>(
            get: {
                guard index >= self.wrappedValue.startIndex, index < self.wrappedValue.endIndex else {
                    return nil
                }
                return self.wrappedValue[index]
            },
            set: { newValue in
                if let newValue = newValue,
                   index >= self.wrappedValue.startIndex,
                   index < self.wrappedValue.endIndex {
                    self.wrappedValue[index] = newValue
                }
            }
        )
    }
}
