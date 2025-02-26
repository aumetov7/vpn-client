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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
