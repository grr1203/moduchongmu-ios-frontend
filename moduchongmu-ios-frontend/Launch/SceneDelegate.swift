//
//  SceneDelegate.swift
//  moduchongmu-ios-frontend
//
//  Created by 이효근 on 30/08/2024.
//

import Foundation
import UIKit
import NaverThirdPartyLogin
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
            NaverThirdPartyLoginConnection
            .getSharedInstance()?
            .receiveAccessToken(URLContexts.first?.url)
        }
}
