//
//  LocationPicker.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 10/5/25.
//

import Foundation

import UIKit
import MapKit
final class LocationTextPickerViewController: UIViewController,
UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, MKLocalSearchCompleterDelegate {

    var onSelect: ((String) -> Void)?

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let searchController = UISearchController(searchResultsController: nil)
    private let completer = MKLocalSearchCompleter()
    private var results: [MKLocalSearchCompletion] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Choose location"
        view.backgroundColor = .systemBackground

        // ✅ Important: so the search controller lives inside THIS VC
        definesPresentationContext = true

        // table setup...
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // search setup...
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func updateSearchResults(for searchController: UISearchController) {
        completer.queryFragment = searchController.searchBar.text ?? ""
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { results.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let r = results[indexPath.row]
        cell.textLabel?.text = r.title
        cell.detailTextLabel?.text = r.subtitle.isEmpty ? nil : r.subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let r = results[indexPath.row]
        var picked = r.title
       
        onSelect?(picked)

        // ✅ First deactivate the search controller
        if searchController.isActive {
            searchController.isActive = false
            // let it deactivate, then dismiss/pop
            DispatchQueue.main.async { [weak self] in self?.dismissSelf() }
        } else {
            dismissSelf()
        }
    }

    // ✅ Works whether presented modally (inside a UINavigationController) or pushed
    private func dismissSelf() {
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
        } else if presentingViewController != nil {
            presentingViewController?.dismiss(animated: true)  // dismiss the hosting nav if any
        } else {
            dismiss(animated: true)
        }
    }
}
