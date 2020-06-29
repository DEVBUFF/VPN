//
//  Settings.swift
//  VPN
//
//  Created by Igor Ryazancev on 6/24/20.
//  Copyright © 2020 DEVBUFF. All rights reserved.
//

import Foundation

final class Settings {
    
    //MARK: - AppSettings
    private struct Keys {
        static let kDidFirstLoad = "kFirstLoad"
        static let kProtectionIsOn = "kProtectionIsOn"
        static let kAutocennectIsOn = "kAutocennectIsOn"
    }
    
    //MARK: - Private methods
    fileprivate static func set(value: Any?, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    fileprivate static func value<T>(for key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
    
}

extension Settings {
    
    var didFirstLoad: Bool {
        get {
            return Settings.value(for: Settings.Keys.kDidFirstLoad) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kDidFirstLoad)
        }
    }
    
    var protectionIsOn: Bool {
        get {
            return Settings.value(for: Settings.Keys.kProtectionIsOn) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kProtectionIsOn)
        }
    }
    
    var autocennectIsOn: Bool {
        get {
            return Settings.value(for: Settings.Keys.kAutocennectIsOn) ?? false
        }
        set {
            Settings.set(value: newValue, for: Settings.Keys.kAutocennectIsOn)
        }
    }
    
}
