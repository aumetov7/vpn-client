//
//  VPNConnectionViewModel.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import Foundation

protocol VPNConnectionViewModel: ObservableObject {
    var isConnected: Bool { get }
    var error: Error? { get }
    
    init(vpnManager: VPNManager)
    
    func toggleVPN()
}

final class VPNConnectionViewModelImpl: VPNConnectionViewModel {
    @Published private(set) var isConnected = false
    @Published private(set) var error: Error? = nil
    
    private let vpnManager: VPNManager
    
    init(vpnManager: VPNManager) {
        self.vpnManager = vpnManager
    }
    
    func toggleVPN() {
        do {
            isConnected
            ? vpnManager.disconnect()
            : try vpnManager.connect()
            
            isConnected.toggle()
        } catch {
            self.error = error
        }
    }
}
