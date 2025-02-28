//
//  NEVPNStatus+Extensions.swift
//  vpn-client
//
//  Created by Akbar Umetov on 28/2/25.
//

import NetworkExtension

extension NEVPNStatus {
    var descriptionString: String {
        switch self {
        case .invalid: return "Invalid"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .reasserting: return "Reasserting"
        case .disconnecting: return "Disconnecting"
        @unknown default: return "Unknown"
        }
    }
}
