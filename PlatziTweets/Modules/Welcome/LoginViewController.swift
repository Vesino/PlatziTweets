//
//  LoginViewController.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/1/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailSwitch: UISwitch!
    
    //MARK: - IBActions
    @IBAction func loginButtonAction() {
        view.endEditing(true)
        performLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        //De esta manera buscamos un string en el UserDefaults
        if let storedEmail = storage.string(forKey: emailKey) {
            emailTextField.text = storedEmail
            emailSwitch.isOn = true
        } else {
            emailSwitch.isOn = false
        }
    }
    
    //MARK: -Metodos privados
    private func setUpUI() {
        loginButton.layer.cornerRadius = 25
    }
    private let emailKey = "email-key"
    private let storage = UserDefaults.standard
    
    private func performLogin() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: .danger).show()
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar la contraseña", style: .warning).show()
            return
        }
        
        // Crear request
        let request = LoginRequest(email: email, password: password)
        SVProgressHUD.show()
        
        //Llamara libreria de red
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success(let user):
                if self.emailSwitch.isOn {
                    self.storage.set(email, forKey: self.emailKey)
                } else {
                    self.storage.removeObject(forKey: self.emailKey)
                }
                self.performSegue(withIdentifier: "showHome", sender: nil)
                SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
            }
        }
        //performSegue(withIdentifier: "showHome", sender: nil)
        //Iniciar sesión aqui
    }
}
