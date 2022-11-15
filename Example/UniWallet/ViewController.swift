//
//  ViewController.swift
//  UniWallet
//
//  Created by leven on 2022/11/6.
//

import UIKit

import UniPass_Swift
import Web3
import BigInt

class ViewController: UIViewController {
    lazy var uniPass = UniPassController(option: UniPassOption(env: .testnet,
                                                               domain: "testnet.wallet.unipass.id",
                                                               proto:"https",
                                                               appSetting: AppSetting(appName: "UniPass Swift", appIcon: "https://avatars.githubusercontent.com/u/16890393?v=4", theme: UniPassTheme.dark, chainType: ChainType.polygon)))
    lazy var inforLabel = UILabel()
    lazy var transactionLabel = UILabel()

    var account: UpAccount?
    
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
        
        
        let sendTransaction = UIButton(type: .custom)
        sendTransaction.setTitle("Send Transaction", for: .normal)
        sendTransaction.addTarget(self, action: #selector(didClickSendTransaction), for: .touchUpInside)
        self.view.addSubview(sendTransaction)
        sendTransaction.frame = CGRect(x: 20, y: 400, width: 300, height: 40)
        self.view.addSubview(self.transactionLabel)
        self.transactionLabel.numberOfLines = 0
        self.transactionLabel.frame = CGRect(x: 20, y: 460, width: 300, height: 100)
    }

    @objc func didClickUniPass() {
        uniPass.connect(in: self) { [weak self]account, errMSg in
            guard let self = self else { return }
            if let account = account {
                self.account = account
                self.inforLabel.text = "Email: \(account.email) \nAddress: \(account.address)"
            } else {
                self.inforLabel.text = "None"
            }
        }
    }
    
    
    @objc func didClickSendTransaction() {
        if let account = account {
            let transaction = TransactionMessage(from: account.address, to: "0x9fFA98D827329941295B28B626B6513B333ebe2c", value: toWei(with: 0.1), data: "0x")
            uniPass.sendTransaction(in: self, transaction) { [weak self] response, erroString in
                guard let self = self else { return }
                if let response = response {
                    self.transactionLabel.text = response
                } else {
                    self.transactionLabel.text = erroString ?? ""
                }
            }
        } else {
            self.transactionLabel.text = "connect to UniPass first"
        }
        
    }
    
    
    func toWei(with eth: Double) -> String {
        let text = "\(eth)"
        let a = text.split(separator: ".").first ?? ""
        let b = text.split(separator: ".").last ?? ""
        
        let ab = ((a + b) as NSString).intValue
        
        let d = BigInt(ab) * BigInt(10).power(18 - b.count)
        return "\(d.description)"
    }
    


}

