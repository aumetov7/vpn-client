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
    
    init() {
        Task {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            if let existingManager = managers.first {
                self.manager = existingManager
            } else {
                try await self.makeManager()
                try await self.manager.saveToPreferences()
                try await self.manager.loadFromPreferences()
            }
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(vpnStatusDidChange(_:)),
                                                   name: .NEVPNStatusDidChange,
                                                   object: self.manager.connection)
        }
    }
    
    @objc private func vpnStatusDidChange(_ notification: Notification) {
        switch self.manager.connection.status {
        case .invalid:
            print("VPN статус изменился: invalid")
        case .disconnected:
            print("VPN статус изменился: disconnected")
        case .connecting:
            print("VPN статус изменился: connecting")
        case .connected:
            print("VPN статус изменился: connected")
        case .reasserting:
            print("VPN статус изменился: reasserting")
        case .disconnecting:
            print("VPN статус изменился: disconnecting")
        @unknown default:
            print("Unknown error")
        }
    }
    
    func makeManager() async throws {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "VLESS VPN"
        
        let protocolConfiguration = NETunnelProviderProtocol()
        
        let vlessURL = "vless://bbfb27eb-21f6-4557-ae46-1f62036aab14@3h-kazakhstan1.09vpn.com:8443?path=/vless/&security=tls&encryption=none&type=ws#u9519564918"
        
        guard let config = VLESSConfig(urlString: vlessURL) else {
            print("Ошибка парсинга")
            return
        }
        
        guard let json = config.toJSON() else {
            print("Ошибка генерации")
            return
        }
        
        print("config: \(json)")
        protocolConfiguration.providerBundleIdentifier = "com.fimacomarketing.testvpn.MyVPNProviderExtension"
        protocolConfiguration.serverAddress = config.serverAddress
        protocolConfiguration.providerConfiguration = ["config": json]
        
        protocolConfiguration.includeAllNetworks = true
        protocolConfiguration.disconnectOnSleep = false
        
        manager.localizedDescription = "VLESS VPN"
        manager.protocolConfiguration = protocolConfiguration
        
        manager.isEnabled = true
        
        self.manager = manager
    }
    
    func connect() throws {
        do {
            try self.manager.connection.startVPNTunnel()
            print("VPN подключен")
        } catch {
            print("Ошибка подключения к VPN: \(error.localizedDescription)")
            throw error
        }
    }
    
    func disconnect() {
        self.manager.connection.stopVPNTunnel()
        print("VPN отключен")
    }
}
