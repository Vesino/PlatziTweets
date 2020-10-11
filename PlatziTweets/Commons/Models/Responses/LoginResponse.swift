//
//  LoginResponse.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/1/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}
