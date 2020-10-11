//
//  WelcomeViewController.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/1/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        loginButton.layer.cornerRadius = 25
    }
}
