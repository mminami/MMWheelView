//
//  LoginClient.swift
//  MMWheelView
//
//  Created by mminami on 2017/12/10.
//  Copyright © 2017 mminami. All rights reserved.
//

import Foundation

enum Result {
    case success
    case failure
}

protocol Login {
    func login(email: String, password: String, completion: ((Result) -> Void))
}

class MockLoginClient: Login {
    static let shared = MockLoginClient()

    func login(email: String, password: String, completion: ((Result) -> Void)) {
        if email == "newspicks.test@gmail.com" && password == "aaaaa" {
            completion(Result.success)
        } else {
            completion(Result.failure)
        }
    }
}
