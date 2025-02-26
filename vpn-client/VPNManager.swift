//
//  VPNManager.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import NetworkExtension

protocol VPNManager {
    func setupVPN() async throws
    func connect() throws
    func disconnect()
}

final class VPNManagerImpl: VPNManager {
    private let vpnManager = NEVPNManager.shared()
    
    func setupVPN() async throws {
        do {
            try await vpnManager.loadFromPreferences()
            
            let protocolConfiguration = NETunnelProviderProtocol()
            protocolConfiguration.providerBundleIdentifier = ""
            protocolConfiguration.serverAddress = ""
            
            vpnManager.protocolConfiguration = protocolConfiguration
            vpnManager.localizedDescription = "VLESS VPN"
            vpnManager.isEnabled = true
            
            try await vpnManager.saveToPreferences()
            print("VPN настройки сохранены успешно")
        } catch {
            print("Ошибка настройки VPN-конфигурации: \(error.localizedDescription)")
            throw error
        }
    }
    
    func connect() throws {
        do {
            try vpnManager.connection.startVPNTunnel()
            print("VPN подключен")
        } catch {
            print("Ошибка подключения к VPN: \(error.localizedDescription)")
            throw error
        }
    }
    
    func disconnect() {
        vpnManager.connection.stopVPNTunnel()
        print("VPN отключен")
    }
}
