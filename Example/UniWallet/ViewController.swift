//
//  ViewController.swift
//  UniWallet
//
//  Created by leven on 2022/11/6.
//

import UIKit

import UniPass_Swift

class ViewController: UIViewController {
    lazy var uniPass = UniPassController(option: UniPassOption(nodeRPC: "https://node.wallet.unipass.id/bsc-testnet",
                                                               env: .testnet,
                                                               domain: "testnet.wallet.unipass.id",
                                                               proto:"https",
                                                               appSetting: AppSetting(appName: "UniPass Swift", appIcon: "", theme: UniPassTheme.dark, chainType: ChainType.bsc)))
    lazy var inforLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gotoUniPass = UIButton(type: .custom)
        gotoUniPass.setTitle("Go To UniPass", for: .normal)
        gotoUniPass.addTarget(self, action: #selector(didClickUniPass), for: .touchUpInside)
        self.view.addSubview(gotoUniPass)
        gotoUniPass.frame = CGRect(x: 20, y: 100, width: 300, height: 40)
        self.view.addSubview(self.inforLabel)
        self.inforLabel.numberOfLines = 0
        self.inforLabel.frame = CGRect(x: 20, y: 160, width: 300, height: 200)
    }

    @objc func didClickUniPass() {
        uniPass.connect(in: self) { [weak self]account, errMSg in
            guard let self = self else { return }
            if let account = account {
                self.inforLabel.text = "Email: \(account.email) \nAddress: \(account.address)"
            } else {
                self.inforLabel.text = "None"
            }
        }
    }

}

