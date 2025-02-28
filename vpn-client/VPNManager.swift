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
    private let vlessURL = "vless://c4828198-f5d0-11ef-b1bc-db90f150bcf7@am1.vpnjantit.com:10002?encryption=none&security=tls&type=ws&path=%2fvpnjantit#testVPN-vpnjantit.com"
    
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
        
        guard let host = config.resolveIPAddress() else {
            throw VLESSConfig.VLESSError.ipError
        }
        
        protocolConfiguration.providerBundleIdentifier = "com.fimacomarketing.testvpn.MyVPNProviderExtension"
        protocolConfiguration.serverAddress = config.serverAddress
        protocolConfiguration.providerConfiguration = ["config": json, "host": host]
        
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

