//
//  VLESSConfig.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import Foundation

struct VLESSConfig {
    let uuid: String
    let serverAddress: String
    let port: Int
    let type: String?
    let encryption: String?
    let host: String?
    let path: String?
    
    init?(urlString: String) {
        guard let url = URL(string: urlString.replacingOccurrences(of: "vless://", with: "https://")) else {
            print("Неверный формат VLESS-ссылки")
            return nil
        }
        
        self.uuid = url.user ?? ""
        self.serverAddress = url.host ?? ""
        self.port = url.port ?? 443
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        self.type = queryItems?.first(where: { $0.name == "type" })?.value
        self.encryption = queryItems?.first(where: { $0.name == "encryption" })?.value
        self.host = queryItems?.first(where: { $0.name == "host" })?.value
        self.path = queryItems?.first(where: { $0.name == "path" })?.value
    }
}
