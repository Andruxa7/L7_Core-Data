//
//  Login.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 7/23/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import Foundation
import Accounts

protocol Loginable {
    func login(complition: @escaping (String?, Error?) -> Void)
}

extension Loginable {
    func getIdentifier(from account: ACAccount, response: (success: Bool, error: Error?)) -> String? {
        let identifier: String?

        if response.success {

            identifier = account.identifier as String?
            print("ACC DESCRIPTION = \(String(describing: identifier))")
        } else {
            if let error = response.error {
                print("ACC ERROR = \(error.localizedDescription)")
            }

            identifier = nil
        }

        return identifier
    }
}


class FacebookLogger: Loginable {
    func login(complition: @escaping (String?, Error?) -> Void) {
        let accountsStore = ACAccountStore() // переменная которая имеет доступ к хранилищу аккаунтов
        let facebook = accountsStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierFacebook) // получаем доступ к "facebook"
        let apiKey = "397756180940849"
        let options = [ACFacebookAppIdKey: apiKey, ACFacebookPermissionsKey: ["email"]] as [String: Any]

        accountsStore.requestAccessToAccounts(with: facebook, options: options) { (success, error) in
            let identifier: String?

            let accounts = accountsStore.accounts(with: facebook)

            if let account = accounts?.last as? ACAccount {
                identifier = self.getIdentifier(from: account, response: (success, error))
            } else {
                identifier = nil
            }

            complition(identifier, error)
        }
    }

}

class TwitterLogger: Loginable {
    func login(complition: @escaping (String?, Error?) -> Void) {
        let accountsStore = ACAccountStore()
        let twitter = accountsStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)

        accountsStore.requestAccessToAccounts(with: twitter, options: nil) { (success, error) in
            let identifier: String?

            let accounts = accountsStore.accounts(with: twitter)

            if let account = accounts?.last as? ACAccount {
                identifier = self.getIdentifier(from: account, response: (success, error))
            } else {
                identifier = nil
            }

            complition(identifier, error)
        }
    }

}

