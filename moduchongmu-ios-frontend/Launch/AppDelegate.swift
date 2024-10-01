//
//  AppDelegate.swift
//  moduchongmu-ios-frontend
//
//  Created by 이효근 on 29/08/2024.
//

import Foundation
import UIKit
import NaverThirdPartyLogin
import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let instance = NaverThirdPartyLoginConnection.getSharedInstance()
        
        // Naver App OAuth 사용 설정
        instance?.isNaverAppOauthEnable = true
        // In-App OAuth 사용 설정 (Safari)
        instance?.isInAppOauthEnable = true
        // 인증 화면을 iPhone의 세로 모드에서만 활성화(true)
        instance?.setOnlyPortraitSupportInIphone(true)
        // App Information 설정
        instance?.serviceUrlScheme = "com.dolanap.moduchongmu-ios-frontend"
        instance?.consumerKey = "OVSo8apILt8vu2sS4W8V"
        instance?.consumerSecret = "3FOgn_W_Ub"
        instance?.appName = "모두의 총무"
        
        KakaoSDK.initSDK(appKey: "7c9b448a9bc8052b35b50d160955c257")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
        
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return true
    }
}
