//
//  UniPassWebViewController.swift
//  UniWallet
//
//  Created by leven on 2022/11/6.
//

import Foundation
import UIKit
public class UniPassController {
    
    var config: UniPassConfig
    
    // 连接web3网络
//    var authProvider: Web3Provider?
    
    public init(option: UniPassOption) {
        let chainType = option.appSetting?.chainType ?? .polygon
        let env = option.env ?? .testnet
        let rpcUrl = option.nodeRPC ?? getRpcUrl(env: env, chainType: chainType)
        let appSetting = option.appSetting ?? AppSetting(appName: nil, appIcon: nil, theme: .dark, chainType: chainType)
        self.config = UniPassConfig(nodeRPC: rpcUrl, chainType: chainType, env: env, domain: option.domain ?? upDomain, proto: option.proto ?? "https", appSetting: appSetting)
    }
    
    
    public func connect(in vc: UIViewController, complete:  @escaping ((UpAccount?, String?) -> Void)) {
        if let upAccount = Storage.getUpAccount() {
            complete(upAccount, nil)
        } else {
            let url = getWalletUrl(messageType: .upConnect, domain: config.domain, proto: config.proto)
            let connectVc = ConnectPageController(url: url, appSetting: config.appSetting) { account, errMsg in
                if let account = account {
                    Storage.saveUpAccount(account: account)
                }
                complete(account, errMsg)
            }
            vc.present(UINavigationController(rootViewController: connectVc), animated: true, completion: nil)
        }
    }
    
}
