import SwiftUI
import WebKit
import UIKit
import Combine
// login
import NaverThirdPartyLogin
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import AuthenticationServices

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
        webView.backgroundColor = UIColor(named: "bgFrameBack")
        webView.navigationDelegate = context.coordinator  // 웹보기의 탐색 동작을 관리하는 데 사용하는 개체
        webView.allowsBackForwardNavigationGestures = false  // 가로로 스와이프 동작이 페이지 탐색을 앞뒤로 트리거하는지 여부
        webView.scrollView.isScrollEnabled = false  // 웹보기와 관련된 스크롤보기에서 스크롤 가능 여부
        webView.isInspectable = true
        
        webView.load(URLRequest(url: url))  // 지정된 URL 요청 개체에서 참조하는 웹 콘텐츠를로드하고 탐색
        
        return webView
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    class Coordinator : NSObject, WKNavigationDelegate {
        var parent: MainWebView
        var webView: WKWebView?
        var foo: AnyCancellable? = nil
        
        // 생성자
        init(_ uiWebView: MainWebView) {
            self.parent = uiWebView
            self.webView = parent.webView
            super.init()
            let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
            naverLoginInstance?.delegate = self
            
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

struct WebViewEvent: Codable {
    let action: String
    let type: String
}
extension MainWebView.Coordinator: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        switch message.name {
        case "moChong":
            if let tmp = message.body as? [String:String] {
                print(tmp)
            } else if let bodyString = message.body as? String {
                print(bodyString)
                var data:WebViewEvent? = nil
                if let jsonData = bodyString.data(using: .utf8) {
                    do{
                        data = try JSONDecoder().decode(WebViewEvent.self, from: jsonData)
                    }
                    catch {
                        print("JSON 디코딩 오류: \(error)")
                    }
                    guard let verifiedData = data else { return }
                    
                    // WebView Event Action에 따라 동작
                    switch verifiedData.action {
                    case "log":
                        print("log", verifiedData)
                        
                        // Login Logic
                    case "login":
                        if(verifiedData.type == "naver") {
                            // Naver Login UI Open
                            NaverThirdPartyLoginConnection.getSharedInstance().delegate = self
                            NaverThirdPartyLoginConnection.getSharedInstance().requestThirdPartyLogin()
                        }
                        else if(verifiedData.type == "kakao") {
                            if (UserApi.isKakaoTalkLoginAvailable()) {
                                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("loginWithKakaoTalk() success.")
                                        _ = oauthToken
                                        responseToWebView(webView: self.webView, accessToken: oauthToken!.accessToken)
                                    }
                                }
                            } else {
                                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("loginWithKakaoAccount() success.")
                                        responseToWebView(webView: self.webView, accessToken: oauthToken!.accessToken)
                                    }
                                }
                            }
                        }
                        else if (verifiedData.type == "google") {
                            guard let viewController = UIApplication.getMostTopViewController() else { return }
                            let config = GIDConfiguration(clientID: "780202279961-h4n1arr48o1mihs6dtuv67ag0oobh0p2.apps.googleusercontent.com")
                            GIDSignIn.sharedInstance.configuration = config
                            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { signInResult, error in
                                guard error == nil else { return }
                                print("google login success")
                                guard let result = signInResult else {
                                    print("No sign-in result available")
                                    return
                                }
                                responseToWebView(webView: self.webView, accessToken: result.user.idToken!.tokenString)
                            }
                        }
                        else if (verifiedData.type == "apple"){
                            let appleIDProvider = ASAuthorizationAppleIDProvider()
                            let request = appleIDProvider.createRequest()
                            request.requestedScopes = [.fullName, .email]
                            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                            authorizationController.delegate = self
                            authorizationController.presentationContextProvider = self
                            authorizationController.performRequests()
                        }
                        
                    default:
                        print("data", verifiedData)
                        let code = "window.initContent('hello')"
                        webView?.evaluateJavaScript(code)}
                }
            } else {
                print("error")
            }
        default:
            break
        }
    }
}

// Naver Login 사용자 로그인 후 Callback 처리
extension MainWebView.Coordinator: NaverThirdPartyLoginConnectionDelegate {
    // NaverThirdPartyLoginConnectionDelegate 메서드 구현
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        // 인증 코드로 액세스 토큰을 요청한 후 처리 (첫 id, paswword 입력 로그인)
        let optionalAccessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken
        if let accessToken = optionalAccessToken {
            print("Successfully received access token with auth code")
            responseToWebView(webView: self.webView, accessToken: accessToken)
        }
    }
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        // 리프레시 토큰으로 액세스 토큰을 요청한 후 처리
        let optionalAccessToken = NaverThirdPartyLoginConnection.getSharedInstance().accessToken
        if let accessToken = optionalAccessToken {
            print("Successfully refreshed access token")
            responseToWebView(webView: self.webView, accessToken: accessToken)
        }
    }
    func oauth20ConnectionDidFinishDeleteToken() {
        // 토큰 삭제 완료 후 처리
        print("Token deleted successfully")
    }
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        // 오류 처리
        print("Failed with error: \(error.localizedDescription)")
    }
}

//
extension MainWebView.Coordinator:ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("Apple ID Credential received: \(userIdentifier)")
            if let tokenData = appleIDCredential.identityToken,
               let tokenString = String(data: tokenData, encoding: .utf8) {
                responseToWebView(webView: self.webView, accessToken: tokenString)
            }
        }
    }
    
    // Apple 로그인 실패 시 처리
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple ID Authorization failed: \(error.localizedDescription)")
    }
    
    // Apple 로그인 프레젠테이션 컨텍스트 제공
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

func responseToWebView(webView: WKWebView?, accessToken: String) {
    print("send access token to webview", accessToken)
    let jsonData = try? JSONSerialization.data(withJSONObject: ["accessToken": accessToken], options: [])
    if let jsonData = jsonData, let string = String(data: jsonData, encoding: .utf8) {
        webView?.evaluateJavaScript("window.initContent('\(string)')")
    }
}
