//
//  VPNConnectionViewModel.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import Foundation

protocol VPNConnectionViewModel: ObservableObject {
    var isConnected: Bool { get }
    
    init(vpnManager: VPNManager)
    
    func toggleVPN()
}

final class VPNConnectionViewModelImpl: VPNConnectionViewModel {
    @Published private(set) var isConnected = false
    
    private let vpnManager: VPNManager
    
    init(vpnManager: VPNManager) {
        self.vpnManager = vpnManager
    }
    
    func toggleVPN() {
        do {
            if isConnected {
                vpnManager.disconnect()
            } else {
                try vpnManager.connect()
            }
            
            isConnected.toggle()
        } catch {
            print("Ошибка VPN: \(error.localizedDescription)")
        }
    }
}
