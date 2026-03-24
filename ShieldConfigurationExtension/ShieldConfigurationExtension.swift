//
//  ShieldConfigurationExtension.swift
//  ShieldConfigurationExtension
//
//  Created by Nguyen Trong Dat on 2/23/26.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .dark, // explicitly dark blur, to avoid default light grey
            backgroundColor: .black, // solid black, 100% opacity
            icon: UIImage(named: "logo-light"),
            title: ShieldConfiguration.Label(
                text: "You Are Blocked",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: application.localizedDisplayName.map {
                    "\($0) is blocked during your focus session."
                } ?? "This app is blocked during your focus session.",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .black
            ),
            primaryButtonBackgroundColor: .white
        )
    }

    override func configuration(shielding application: Application, in category: ActivityCategory)
        -> ShieldConfiguration
    {
        return configuration(shielding: application)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: .dark, // explicitly dark blur, to avoid default light grey
            backgroundColor: .black, // solid black, 100% opacity
            icon: UIImage(named: "logo-light"),
            title: ShieldConfiguration.Label(
                text: "You Are Blocked",
                color: .white
            ),
            subtitle: ShieldConfiguration.Label(
                text: webDomain.domain.map {
                    "\($0) is blocked during your focus session."
                } ?? "This website is blocked during your focus session.",
                color: .white
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: .black
            ),
            primaryButtonBackgroundColor: .white
        )
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory)
        -> ShieldConfiguration
    {
        return configuration(shielding: webDomain)
    }
}
