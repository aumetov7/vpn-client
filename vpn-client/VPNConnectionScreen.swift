//
//  VPNConnectionScreen.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import SwiftUI

struct VPNConnectionScreen<VM: VPNConnectionViewModel>: View {
    @StateObject private var viewModel: VM
    
    init(viewModel: VM) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            Button(action: viewModel.toggleVPN) {
                Text(viewModel.isConnected ? "Отключить VPN" : "Подключить VPN")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isConnected ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
