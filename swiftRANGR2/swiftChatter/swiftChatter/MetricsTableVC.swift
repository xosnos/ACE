//
//  MetricsTableVC.swift
//  swiftChatter
//
//  Created by Steven Nguyen on 3/18/22.
//

import Foundation
import UIKit

final class MetricsTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.addAction(UIAction(handler: refreshTimeline), for: UIControl.Event.valueChanged)
        
        refreshTimeline(nil)
    }
    
    // MARK:- TableView handlers

    override func numberOfSections(in tableView: UITableView) -> Int {
        // how many sections are in table
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many rows per section
        return MetricsStore.shared.log.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // event handler when a cell is tapped
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // populate a single cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MetricsTableCell", for: indexPath) as? MetricsTableCell else {
            fatalError("No reusable cell!")
        }
        
        let metrics = MetricsStore.shared.log[indexPath.row]
        cell.backgroundColor = (indexPath.row % 2 == 0) ? .systemGray5 : .systemGray6
        cell.timeStampLabel.text = metrics.timeStamp
        cell.clubLabel.text = "Club: \(metrics.club ?? "N/A")"
        cell.launchAngleLabel.text = "Launch Angle: \(metrics.launchAngle ?? "N/A") °"
        cell.launchSpeedLabel.text = "Lauch Speed: \(metrics.launchSpeed ?? "N/A") mph"
        cell.hangTimeLabel.text = "Hang Time: \(metrics.hangTime ?? "N/A") sec(s)"
        cell.distanceLabel.text = "Distance: \(metrics.distance ?? "N/A") yd(s)"
        return cell
    }
    private func refreshTimeline(_ sender: UIAction?) {
        MetricsStore.shared.getShotLog { success in
            DispatchQueue.main.async {
                if success {
                    self.tableView.reloadData()
                }
                // stop the refreshing animation upon completion:
                self.refreshControl?.endRefreshing()
            }
        }
    }
}


