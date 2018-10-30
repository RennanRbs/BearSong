//
//  RefreshTabbarDelegate.swift
//  BearSong
//
//  Created by Rennan Rebouças on 27/10/18.
//  Copyright © 2018 Rennan Rebouças. All rights reserved.
//

import Foundation

protocol RefreshTabbarDelegate {
    func oneRefresh()
    func run(after wait: TimeInterval, closure: @escaping () -> Void)
    func refresh()
}
