//
//  PacketTunnelProvider.swift
//  MyVPNProviderExtension
//
//  Created by Akbar Umetov on 27/2/25.
//

import NetworkExtension
import LibXray
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var serverAddress: String?
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        os_log("PacketTunnelProvider: startTunnel вызван", log: OSLog.default, type: .info)
        
        guard let protocolConfiguration = protocolConfiguration as? NETunnelProviderProtocol,
              let providerConfiguration = protocolConfiguration.providerConfiguration,
              let jsonConfig = providerConfiguration["config"] as? String
        else {
            os_log("Отсутствует JSON-конфигурация", log: OSLog.default, type: .error)
            return
        }
        
        os_log("JSON-конфигурация: %{PUBLIC}@", log: OSLog.default, type: .debug, jsonConfig)
        let tunnelSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "38.107.234.57")
        
        let ipv4Settings = NEIPv4Settings(addresses: ["10.8.0.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        tunnelSettings.ipv4Settings = ipv4Settings
        
        tunnelSettings.dnsSettings = NEDNSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        
        setTunnelNetworkSettings(tunnelSettings) { error in
            if let error = error {
                os_log("Ошибка установки туннельных настроек: %{PUBLIC}@", log: OSLog.default, type: .error, error.localizedDescription)
                completionHandler(error)
            } else {
                os_log("Туннельные настройки установлены", log: OSLog.default, type: .info)
                LibXrayRunXray(jsonConfig)
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        os_log("PacketTunnelProvider: stopTunnel вызван", log: OSLog.default, type: .info)
        LibXrayStopXray()
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
}

private struct Configuration {
    let address: String

    init(proto: NETunnelProviderProtocol) throws {
        guard let serverAddress = proto.serverAddress else {
            throw NEVPNError(.configurationInvalid)
        }
        self.address = serverAddress
    }
}
