//
//  ConnectPage.swift
//  UniWallet
//
//  Created by leven on 2022/11/6.
//

import Foundation
import UIKit
import WebKit

public class ConnectPageController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {

    private let titleKeyPath = "title"
    private let estimatedProgressKeyPath = "estimatedProgress"

    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.minimumFontSize = 10
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.processPool = WKProcessPool()
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name: "onConnectReady")
        config.userContentController.add(self, name: "onConnectResponse")
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.addObserver(self, forKeyPath: titleKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: estimatedProgressKeyPath, options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        if #available(iOS 9.0, *) {
            webView.allowsLinkPreview = true
        }
        webView.navigationDelegate = self
        webView.backgroundColor = UIColor.white
        return webView
    }()
    
    let complete: ((UpAccount?, String?) -> Void)
    
    let url: String
    
    let appSetting: AppSetting
    
    init(url: String, appSetting: AppSetting, complete: @escaping ((UpAccount?, String?) -> Void)) {
        self.url = url
        self.appSetting = appSetting
        self.complete = complete
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.webView.frame = self.view.bounds
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.configuration.userContentController.addUserScript(WKUserScript(source: "window.onConnectReady = function(){location.reload();}", injectionTime: .atDocumentStart, forMainFrameOnly: false))
        self.view.addSubview(self.webView)
        if let webUrl = URL(string: url) {
            self.webView.load(URLRequest(url: webUrl))
        }
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == titleKeyPath {
            self.title = change?[.newKey] as? String
        }
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        webView.evaluateJavaScript("window.onConnectReady = function(){location.reload();}", completionHandler: nil)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
    }
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.performDefaultHandling, nil)
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        decisionHandler(.allow, preferences)
    }
    
    
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "onConnectReady" {
            let value: [String: Any] = ["type": "UP_LOGIN",
                                        "appSetting" : ["appName" : self.appSetting.appName ?? "", "appIcon": self.appSetting.appIcon ?? "" , "chain" : self.appSetting.chainType?.rawValue ?? "", "theme": self.appSetting.theme?.rawValue ?? ""]]
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed]), let jsonString = String.init(data: jsonData, encoding: .utf8) {
                self.webView.evaluateJavaScript("window.onConnectPageReady(\"\(jsonString)\"") { _, error in
                    
                }
            }
        }
        if message.name == "onConnectResponse" {
            var body = message.body as? [String: Any]
            if body == nil {
                body = (message.body as? [Any])?.first as? [String: Any]
            }
            if let body = body {
                if let type = body["type"] as? String {
                    if type == "UP_RESPONSE" {
                        if let payloadData = (body["payload"] as? String)?.data(using: .utf8),  let json = try? JSONSerialization.jsonObject(with: payloadData, options: [.fragmentsAllowed]) as? [String: Any] {
                            
                            if (json["type"] as? String) == "DECLINE" {
                                self.complete(nil, "user reject connect")
                                self.gotBack()
                            }
                            
                            if let data = json["data"] as? [String: String] {
                                let upAccount = UpAccount(address: data["address"] ?? "" , email: data["address"] ?? "", newborn: data["address"] ?? "")
                                self.complete(upAccount, nil)
                                self.gotBack()
                            } else {
                                self.complete(nil, "data decode error")
                                self.gotBack()
                            }
                        }
                    }
                }
            } else {
                self.complete(nil, "invalid body data")
                self.gotBack()
            }
        }
    }
    
    func gotBack() {
        if (self.navigationController?.viewControllers.count ?? 0) > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
