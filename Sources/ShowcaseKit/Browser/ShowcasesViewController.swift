//
//  ShowcasesViewController.swift
//  ShowcaseKit-iOS
//
//  Created by Jérôme Alves on 09/09/2019.
//  Copyright © 2019 Heetch. All rights reserved.
//

import Foundation
import UIKit

public class ShowcasesViewController: UITableViewController {

    public static func present(
        over presenter: UIViewController,
        showcases: [ShowcaseDescription] = .all,
        wrapInNavigationController: Bool = true
        ) {
        let list = ShowcasesViewController(showcases: showcases)

        if wrapInNavigationController {
            let nav = UINavigationController(rootViewController: list)
            list.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: list,
                action: #selector(dismissFromPresenting)
            )
            presenter.present(nav, animated: true)
        } else {
            presenter.present(list, animated: true)
        }
    }

    @objc private func dismissFromPresenting() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private let isRoot: Bool
    private let viewModel: ShowcasesViewModel

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barStyle = .default
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()

    public convenience init(showcases: [ShowcaseDescription]) {
        self.init(viewModel: ShowcasesViewModel(showcases: showcases))
    }

    public init(viewModel: ShowcasesViewModel = ShowcasesViewModel(), isRoot: Bool = true) {
        self.isRoot = isRoot
        self.viewModel = viewModel
        super.init(style: .grouped)
        if #available(iOS 11.0, *) {
            if isRoot {
                navigationItem.largeTitleDisplayMode = .automatic
                navigationItem.searchController = searchController
                navigationItem.hidesSearchBarWhenScrolling = false
            } else {
                navigationItem.largeTitleDisplayMode = .never
            }
        }
        title = "Showcases"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        class SubtitleCell: UITableViewCell {
            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            }
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }

        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: "ShowcaseCell")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        viewModel.onDataUpdate = { [weak self] in
            self?.tableView.reloadData()
        }

        if #available(iOS 11.0, *), isRoot, let searchQuery = ShowcasesSettings.shared.searchQuery, searchQuery.isEmpty == false {
            searchController.searchBar.text = searchQuery
            if let showcase = viewModel.uniqueShowcase {
                show(showcase)
            }
        }
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentShowcaseReference = nil
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.section(at: section).name
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.section(at: section).items.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowcaseCell", for: indexPath)
        cell.textLabel?.attributedText = viewModel.attributedTitle(for: item)
        cell.detailTextLabel?.attributedText = viewModel.attributedSubtitle(for: item)
        cell.imageView?.image = viewModel.image(for: item)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if #available(iOS 11.0, *), isRoot {
            searchController.searchBar.resignFirstResponder()
        }
        DispatchQueue.main.async {
            self.show(self.viewModel.item(at: indexPath))
        }
    }

    private func show(_ item: ShowcasesViewModel.Item) {
        switch item {
        case .folder(let title, let content):
            let viewModel = ShowcasesViewModel(showcases: content)
            let next = ShowcasesViewController(viewModel: viewModel, isRoot: false)
            next.title = title
            navigationController!.pushViewController(next, animated: true)
        case .showcase(let showcase):
            show(showcase)
        }
    }

    private var currentShowcaseReference: AnyObject?
    private func show(_ showcase: ShowcaseDescription) {
        guard let navigationController = navigationController else {
            return
        }

        let factory = showcase.classType.init()
        let viewController = factory.makeViewController()

        viewController.title = showcase.title
        viewController.hidesBottomBarWhenPushed = true
        if #available(iOS 11.0, *) {
            viewController.navigationItem.largeTitleDisplayMode = .never
        }

        switch showcase.presentationMode {
        case .automatic:
            if viewController is UINavigationController {
                navigationController.present(viewController, animated: true)
            } else {
                navigationController.pushViewController(viewController, animated: true)
            }
        case .modal:
            navigationController.present(viewController, animated: true)
        }

        currentShowcaseReference = factory
    }

}

extension ShowcasesViewController: UISearchBarDelegate {

}

extension ShowcasesViewController: UISearchControllerDelegate {
    public func willDismissSearchController(_ searchController: UISearchController) {
        viewModel.searchQuery = nil
    }
}

extension ShowcasesViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchQuery = searchController.searchBar.text
    }
}

