//
//  VPNConnectionViewModel.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import Foundation

protocol VPNConnectionViewModel: ObservableObject {
    var isConnected: Bool { get }
    var showAlert: Bool { get set }
    var error: Error? { get }
    
    init(vpnManager: VPNManager)
    
    func toggleVPN()
}

final class VPNConnectionViewModelImpl: VPNConnectionViewModel {
    @Published private(set) var isConnected = false
    @Published private(set) var error: Error? = nil
    
    @Published var showAlert = false
    
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
            self.showAlert = true
            self.error = error
        }
    }
}
