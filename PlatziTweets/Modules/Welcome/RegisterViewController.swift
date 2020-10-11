//
//  RegisterViewController.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/1/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var resgisterButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var namesTextField: UITextField!
    
    //MARK: - IBActions
    @IBAction func registerButtonAction() {
        view.endEditing(true)
        performRegister()
      }
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    //MARK: -Metodos privados
    
    private func setUpUI() {
        resgisterButton.layer.cornerRadius = 25
    }
    
    private func performRegister() {
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: .danger).show()
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar la contraseña", style: .warning).show()
            return
        }
        
        guard let name = namesTextField.text, !name.isEmpty else {
                   NotificationBanner(title: "Error", subtitle: "Debes especificar tu nombre y apellido", style: .warning).show()
                   return
               }
        
        //Crear request:
        
        let register = RegisterRequest(email: email, password: password, names: name)
        //Indicar la carga
        SVProgressHUD.show()
        
        //Llamar al servicio utilizando simple networking
        SN.post(endpoint: Endpoints.register, model: register) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
                   SVProgressHUD.dismiss()
                   switch response {
                   case .success(let user):
                       self.performSegue(withIdentifier: "showHome", sender: nil)
                       SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                       
                   case .error(let error):
                       NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
                   case .errorResult(let entity):
                       NotificationBanner(subtitle: entity.error, style: .warning).show()
                   }
               }
        }
        
        //performSegue(withIdentifier: "showHome", sender: nil)
        //Iniciar sesión aqui
}
