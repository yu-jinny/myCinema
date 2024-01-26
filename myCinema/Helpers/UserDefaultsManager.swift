//
//  UserDefaultsManager.swift
//  myCinema
//
//  Created by t2023-m0028 on 1/19/24.
//

import Foundation

struct User {
    var username: String
    var password: String
    var name: String
    var birthdate: String
}

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    
    // 특정 키에 사용자 정보를 저장하는 메서드
    func saveUserInfo(user: User) {
        userDefaults.set(user.username, forKey: "username")
        userDefaults.set(user.password, forKey: "password")
        userDefaults.set(user.name, forKey: "name")
        userDefaults.set(user.birthdate, forKey: "birthdate")
        
        // 아이디를 중복 저장하지 않도록 추가
        saveUsername(user.username)
    }
    
    // 특정 키로부터 사용자 정보를 불러오는 메서드
    func loadUserInfo() -> User? {
        guard let username = userDefaults.string(forKey: "username"),
              let password = userDefaults.string(forKey: "password"),
              let name = userDefaults.string(forKey: "name"),
              let birthdate = userDefaults.string(forKey: "birthdate") else {
            return nil
        }
        
        return User(username: username, password: password, name: name, birthdate: birthdate)
    }
    
    // 사용자 정보 삭제
    func removeUserInfo() {
        userDefaults.removeObject(forKey: "username")
        userDefaults.removeObject(forKey: "password")
        userDefaults.removeObject(forKey: "name")
        userDefaults.removeObject(forKey: "birthdate")
    }
    
    // 저장된 사용자명 목록을 가져오는 메서드
    func getSavedUsernames() -> [String] {
        guard let usernames = userDefaults.array(forKey: "usernames") as? [String] else {
            return []
        }
        return usernames
    }
    
    // 새로운 사용자명을 저장하는 메서드
    func saveUsername(_ username: String) {
        var usernames = getSavedUsernames()
        usernames.append(username)
        userDefaults.set(usernames, forKey: "usernames")
    }
    
    // 사용자명을 제거하는 메서드
    func removeUsername(_ username: String) {
        var usernames = getSavedUsernames()
        usernames.removeAll { $0 == username }
        userDefaults.set(usernames, forKey: "usernames")
    }
}
