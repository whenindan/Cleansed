//
//  DeviceActivityReportExtension.swift
//  DeviceActivityReportExtension
//
//  Created by Nguyen Trong Dat on 2/23/26.
//

import DeviceActivity
import ExtensionKit
import SwiftUI

@main
struct DeviceActivityReportExtension: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
