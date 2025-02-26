//
//  vpn_clientApp.swift
//  vpn-client
//
//  Created by Akbar Umetov on 24/2/25.
//

import SwiftUI

@main
struct vpn_clientApp: App {
    var body: some Scene {
        WindowGroup {
            VPNConnectionBuilder.build()
        }
    }
}
