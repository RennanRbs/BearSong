//
//  BaseViewController.swift
//  BearSong
//
//  Base class for standardized pages with common layout and error/empty state helpers.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func setupNavigationBar(title: String?) {
        navigationItem.title = title
    }

    func showError(message: String, retryAction: (() -> Void)? = nil) {
        // Override in subclasses or use EmptyStateView
    }

    func showEmptyState(message: String, retryAction: (() -> Void)? = nil) {
        // Override in subclasses or use EmptyStateView
    }
}
