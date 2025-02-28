//
//  VPNManager.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import NetworkExtension

protocol VPNManager {
    func connect() throws
    func disconnect()
}

final class VPNManagerImpl: VPNManager {
    private var manager = NETunnelProviderManager()
    private let vlessURL = "vless://bbfb27eb-21f6-4557-ae46-1f62036aab14@3h-kazakhstan1.09vpn.com:8443?path=/vless/&security=tls&encryption=none&type=ws#u9519564918"
    
    init() {
        Task {
            try await setupManager()
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(vpnStatusDidChange(_:)),
                name: .NEVPNStatusDidChange,
                object: self.manager.connection
            )
        }
    }
    
    func connect() throws {
        do {
            try self.manager.connection.startVPNTunnel()
        } catch {
            throw error
        }
    }
    
    func disconnect() {
        self.manager.connection.stopVPNTunnel()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: .NEVPNStatusDidChange,
            object: self.manager.connection
        )
    }
}

private extension VPNManagerImpl {
    func setupManager() async throws {
        let managers = try await NETunnelProviderManager.loadAllFromPreferences()
        if let existingManager = managers.first {
            self.manager = existingManager
        } else {
            try await self.makeManager()
            try await self.manager.saveToPreferences()
            try await self.manager.loadFromPreferences()
        }
    }
    
    func makeManager() async throws {
        let manager = NETunnelProviderManager()
        
        let protocolConfiguration = NETunnelProviderProtocol()

        guard let config = VLESSConfig(urlString: vlessURL) else {
            throw VLESSConfig.VLESSError.parsingError
        }
        
        guard let json = config.toJSON() else {
            throw VLESSConfig.VLESSError.jsonError
        }
        
        protocolConfiguration.providerBundleIdentifier = "com.fimacomarketing.testvpn.MyVPNProviderExtension"
        protocolConfiguration.serverAddress = config.serverAddress
        protocolConfiguration.providerConfiguration = ["config": json, "host": "38.107.234.57"]
        
        protocolConfiguration.includeAllNetworks = true
        protocolConfiguration.disconnectOnSleep = false
        
        manager.localizedDescription = "VLESS VPN"
        manager.protocolConfiguration = protocolConfiguration
        manager.isEnabled = true
        
        self.manager = manager
    }
    
    @objc func vpnStatusDidChange(_ notification: Notification) {
        print("Status: \(self.manager.connection.status.descriptionString)")
    }
}

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
