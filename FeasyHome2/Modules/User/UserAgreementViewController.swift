//
//  UserAgreementViewController.swift
//  FeasyHome2
//
//  Created by wenjie zeng on 2025/3/4.
//

import UIKit
import WebKit

class UserAgreementViewController: UIViewController, WKNavigationDelegate {
    private var webView:WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        view.addSubview(webView)
        webView.navigationDelegate = self
        if let url = URL(string: "https://api.feasycom.com/feasyhome/index/Article/helpCenter") {
            let request = URLRequest(url:url)
            webView.load(request)
        }
    }
    

}
