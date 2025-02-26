//
//  VPNConnectionBuilder.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import SwiftUI

final class VPNConnectionBuilder {
    static func build() -> some View {
        let vpnManager = VPNManagerImpl()
        let viewModel = VPNConnectionViewModelImpl(vpnManager: vpnManager)
        let view = VPNConnectionScreen(viewModel: viewModel)
        
        return view
    }
}
