//
//  AboutViewController.swift
//  FeasyHome2
//
//  Created by wenjie zeng on 2025/3/4.
//

import UIKit
import WebKit

class AboutViewController: UIViewController, WKNavigationDelegate {
    private var webView:WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView = WKWebView(frame: self.view.bounds, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        view.addSubview(webView)
        if let url = URL(string: "https://api.feasycom.com/feasyhome/index/Article/aboutUs") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    


}
