//
//  LayoutConstants.swift
//  BearSong
//
//  Single source of truth for spacing, insets and corner radius across the app.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum LayoutConstants {

    /// Standard horizontal/vertical padding for screen edges and content.
    static let paddingStandard: CGFloat = 16

    /// Spacing between collection view cells (lines and items).
    static let cellSpacing: CGFloat = 8

    /// Corner radius for cards and medium elements (e.g. profile cards, cell images).
    static let cornerRadiusMedium: CGFloat = 20

    /// Corner radius for large elements (e.g. profile photo).
    static let cornerRadiusLarge: CGFloat = 40

    /// Corner radius for small elements when needed.
    static let cornerRadiusSmall: CGFloat = 12

    /// Border width for profile image and cards.
    static let borderWidth: CGFloat = 5

    // MARK: - SwiftUI
    /// Section padding for SwiftUI (same values as sectionInset).
    static var sectionPadding: EdgeInsets {
        EdgeInsets(top: paddingStandard, leading: paddingStandard, bottom: paddingStandard, trailing: paddingStandard)
    }
}

#if canImport(UIKit)
extension LayoutConstants {
    /// Section inset for collection views (all sides). UIKit only.
    static var sectionInset: UIEdgeInsets {
        UIEdgeInsets(top: paddingStandard, left: paddingStandard, bottom: paddingStandard, right: paddingStandard)
    }
}
#endif
