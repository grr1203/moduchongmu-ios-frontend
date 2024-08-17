//
//  WebView.swift
//  moduchongmu-ios-frontend
//
//  Created by 이효근 on 16/08/2024.
//

import Foundation
import WebKit

class ViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: self.view.frame)
        self.view = webView
        
        let url = URL(string: "https://moduchongmu.com/")
        let request = URLRequest(url: url!)
        
        webView.allowsBackForwardNavigationGestures = true // 뒤로가기 제스처 허용
        
        webView.configuration.preferences.javaScriptEnabled = true
        
        webView.load(request)
    }
}

#Preview {
    ViewController()
}
