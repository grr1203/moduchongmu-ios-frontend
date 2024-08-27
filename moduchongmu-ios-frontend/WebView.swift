import SwiftUI
import WebKit
import UIKit
import Combine


struct MainWebView: UIViewRepresentable {
    let url:URL
    let webView = WKWebView()
    
    func makeUIView(context: Context) -> WKWebView {
        // JavaScript가 사용자 상호 작용없이 창을 열 수 있는지 여부
        let configuration = webView.configuration
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        configuration.preferences = preferences
        configuration.userContentController.add(self.makeCoordinator(), name: "moChong")
        configuration.userContentController.add(self.makeCoordinator(), name: "callBack")
        webView.backgroundColor = UIColor(named: "bgFrameBack")
        webView.navigationDelegate = context.coordinator  // 웹보기의 탐색 동작을 관리하는 데 사용하는 개체
        webView.allowsBackForwardNavigationGestures = false  // 가로로 스와이프 동작이 페이지 탐색을 앞뒤로 트리거하는지 여부
        webView.scrollView.isScrollEnabled = false  // 웹보기와 관련된 스크롤보기에서 스크롤 가능 여부
        
        webView.load(URLRequest(url: url))  // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
        
        return webView
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
//    func callJavaScriptFunction(_ webView: WKWebView, functionName: String, arguments: [String]) {
//        let argumentsString = arguments.joined(separator: ",")
//        let script = "\(functionName)(\(argumentsString));"
//        webView.evaluateJavaScript(script) { (result, error) in
//            if let error = error {
//                print("JavaScript 호출 오류: \(error.localizedDescription)")
//            } else {
//                print("JavaScript 호출 결과: \(String(describing: result))")
//            }
//        }
//    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        var parent: MainWebView
        var webView: WKWebView?
        var foo: AnyCancellable? = nil
        // 생성자
        init(_ uiWebView: MainWebView) {
            self.parent = uiWebView
            self.webView = parent.webView
        }
        // 소멸자
        deinit {
            foo?.cancel()
        }
        // 지정된 기본 설정 및 작업 정보를 기반으로 새 콘텐츠를 탐색 할 수있는 권한을 대리인에게 요청
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            return decisionHandler(.allow)
        }
        // 기본 프레임에서 탐색이 시작되었음
        func webView(_ webView: WKWebView,
                     didStartProvisionalNavigation navigation: WKNavigation!) {
            
            print("기본 프레임에서 탐색이 시작되었음")
        }
        // 웹보기가 기본 프레임에 대한 내용을 수신하기 시작했음
        func webView(_ webView: WKWebView,
                     didCommit navigation: WKNavigation!) {
            print("내용을 수신하기 시작");
        }
        // 탐색이 완료 되었음
        func webView(_ webview: WKWebView,
                     didFinish: WKNavigation!) {
        }
        // 초기 탐색 프로세스 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation: WKNavigation!,
                     withError: Error) {
            print("초기 탐색 프로세스 중에 오류가 발생했음")
        }
        // 탐색 중에 오류가 발생했음 - Error Handler
        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            print("탐색 중에 오류가 발생했음")
        }
    }
}
extension MainWebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        print(message.name)
        switch message.name {
        case "moChong":
            if let tmp = message.body as? [String:String] {
                print(tmp)
            } else if let tmp = message.body as? String {
                print(tmp)
                //                if let webView = self.webView {
                //                    self.parent.callJavaScriptFunction(webView, functionName: "initContent", arguments: ["arg1", "arg2"])
                //                }
                //                webView.evaluateJavaScript("""
                //                                           moChong.postMessage('productId');
                //                                         """)
                
                let code = "window.initContent('hello')"
                webView?.evaluateJavaScript(code)
            } else {
                print("머 잘못함 수구바위")
            }
            print("hi")
        case "callBack":
            print("정상")
        default:
            break
        }
    }
}


