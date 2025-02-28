//
//  VLESSConfig.swift
//  vpn-client
//
//  Created by Akbar Umetov on 26/2/25.
//

import Foundation
import Darwin

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
}

extension VLESSConfig {
    func toJSON() -> String? {
        var user: [String: Any] = [
            "id": uuid,
            "encryption": encryption ?? "none",
            "level": 0,
            "security": security ?? "none"
        ]
        
        if security?.lowercased() == "tls" {
            let sni = host ?? serverAddress
            user["tlsSettings"] = [
                "serverName": sni
            ]
        }
        
        let outbound: [String: Any] = [
            "protocol": "vless",
            "settings": [
                "vnext": [
                    [
                        "address": serverAddress,
                        "port": port,
                        "users": [ user ]
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
        
        var config: [String: Any] = [
            "outbounds": [ outbound ]
        ]
        
        if let tag = tag {
            config["tag"] = tag
        }
        
        if
            let jsonData = try? JSONSerialization.data(withJSONObject: config, options: .prettyPrinted),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString.replacingOccurrences(of: "\\/", with: "/")
        }
        
        return nil
    }
    
    func resolveIPAddress() -> String? {
        var hints = addrinfo(
            ai_flags: AI_PASSIVE,
            ai_family: AF_INET,
            ai_socktype: SOCK_STREAM,
            ai_protocol: IPPROTO_TCP,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil)
        
        var info: UnsafeMutablePointer<addrinfo>?
        let status = getaddrinfo(serverAddress, nil, &hints, &info)
        guard status == 0, let result = info else {
            return nil
        }
        defer { freeaddrinfo(result) }
        
        if let addr = result.pointee.ai_addr {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let error = getnameinfo(
                addr, socklen_t(result.pointee.ai_addrlen),
                &hostname, socklen_t(hostname.count),
                nil, 0, NI_NUMERICHOST
            )
            
            if error == 0 {
                return String(cString: hostname)
            }
        }
        return nil
    }
    
    enum VLESSError: Error {
        case parsingError
        case jsonError
        case ipError
    }
}
