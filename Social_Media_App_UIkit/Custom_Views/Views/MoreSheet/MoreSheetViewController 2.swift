//
//  MoreSheetViewController 2.swift
//  Social_Media_App_UIkit
//
//  Created by aplle on 1/2/26.
//

import UIKit
final class MoreSheetViewController: UIViewController {

    private let config: MoreSheetConfig
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerView = MoreSheetHeaderView()

    init(config: MoreSheetConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)

       
    }
    // tune once
     private let rowHeight: CGFloat = 80
     private let extraPadding: CGFloat = 32
     private let headerEstimatedHeight: CGFloat = 90
    
    func estimatedSheetHeight() -> CGFloat {
        var height = extraPadding
        if config.header?.avatar != nil {
            height += 50
        }
        if config.header?.fullName != nil {
            height += 24
        }
        height += CGFloat( config.actions.count) * rowHeight
         
        if config.title != nil {
            height += 30
        }
        if config.message != nil {
            height += 50
        }
            return height
        }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Configure header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.apply(
            header: config.header,
            title: config.title,
            message: config.message
        )

        // Configure table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(MoreActionCell.self, forCellReuseIdentifier: MoreActionCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
      

        view.addSubview(headerView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            // 🔹 Header pinned to top
            headerView.topAnchor.constraint(equalTo: view.topAnchor,constant: 12),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // 🔹 Table below header
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension MoreSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        config.actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = config.actions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreActionCell.reuseID, for: indexPath) as! MoreActionCell
        cell.configure(with: action)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = config.actions[indexPath.row]
        guard action.isEnabled else { return }

        // dismiss first, then run action
        dismiss(animated: true) {
            action.handler()
        }
    }
}

#Preview(){
    MoreSheetViewController(config: MoreSheetConfig(
        header: MoreSheetConfig.Header(
            avatar: .url(Post.mockPost.author.avatarURL),
            username: Post.mockPost.author.username,
            fullName: nil,
            isVerified: Post.mockPost.author.isVerified
        ),
       
        actions: [
            .init(
                id: "copy",
                title: "Copy link",
                subtitle: nil,
                icon: UIImage(systemName: "link"),
                style: .normal,
                isEnabled: true,
                handler: { UIPasteboard.general.string = "your-link-here" }
            ),
            .init(
                id: "report",
                title: "Report",
                subtitle: "This will notify moderators",
                icon: UIImage(systemName: "exclamationmark.bubble"),
                style: .destructive,
                isEnabled: true,
                handler: { print("Report tapped") }
            ),
        ]
    ))
}
