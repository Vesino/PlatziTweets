//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/1/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import Foundation

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let names: String
}
