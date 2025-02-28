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
    let security: String?
    let host: String?
    let path: String?
    let tag: String?
    
    init?(urlString: String) {
        guard let url = URL(string: urlString.replacingOccurrences(of: "vless://", with: "https://")) else {
            print("Неверный формат VLESS-ссылки")
            return nil
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("Ошибка разбора URL")
            return nil
        }
        
        self.uuid = url.user ?? ""
        self.serverAddress = url.host ?? ""
        self.port = url.port ?? 443
        
        let queryItems = components.queryItems ?? []
        self.type = queryItems.first(where: { $0.name == "type" })?.value
        self.encryption = queryItems.first(where: { $0.name == "encryption" })?.value
        self.security = queryItems.first(where: { $0.name == "security" })?.value
        self.host = queryItems.first(where: { $0.name == "host" })?.value
        self.path = queryItems.first(where: { $0.name == "path" })?.value
        self.tag = components.fragment
    }
    
    func toJSON() -> String? {
        var config: [String: Any] = [
            "outbounds": [
                [
                    "protocol": "vless",
                    "settings": [
                        "vnext": [
                            [
                                "address": serverAddress,
                                "port": port,
                                "users": [
                                    [
                                        "id": uuid,
                                        "encryption": encryption ?? "none",
                                        "level": 0,
                                        "security": security ?? "none"
                                    ]
                                ]
                            ]
                        ]
                    ],
                    "streamSettings": [
                        "network": type ?? "ws",
                        "wsSettings": [
                            "path": path ?? "/"
                        ]
                    ]
                ]
            ]
        ]
        
        if let tag = tag {
            config["tag"] = tag
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: config, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return nil
    }
}
