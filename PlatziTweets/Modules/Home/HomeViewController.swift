//
//  HomeViewController.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/2/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class HomeViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    private let cellID = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPost()
    }
    
    private func setupUI() {
        //1. Data source.
        //2. Registrar la celda.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    private func getPost() {
        //1. Indicar carga al usuario
        SVProgressHUD.show()
        
        //2. Consumir el servicio
        SN.get(endpoint: Endpoints.getPost) { (response: SNResultWithEntity<[Post], ErrorResponse>) in
            //Cerramos la carga
            SVProgressHUD.dismiss()
            switch response {
            case .success(let post):
                //Aqui rederizaremos el resultado de éxito
                self.dataSource = post
                self.tableView.reloadData()
                
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
            }
        }
    }
    
    //MARK: -Funciones privadas
    private func deletePostAt(indexPath: IndexPath) {
        //1. indicar carga al usuario
        SVProgressHUD.show()
        
        //2. Obtener el Id del post que vamos a borrar
        let postId = dataSource[indexPath.row].id
        
        //3. con esto preparamos el endpoint para borrar
        let endpoint = Endpoints.delete + postId
        
        //4. Consumir el servicio para borrar el post
        SN.delete(endpoint: endpoint) { (result: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            //Cerramos la carga
            SVProgressHUD.dismiss()
            switch result {
            case .success:
                //1. Borrar el post del data source
                //2. Borrarlo la celda de la tabla
                self.dataSource.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
            }
        }
    }
}
//MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Borrar") { (_, _) in
            //Aqui borramos el Tweet
            self.deletePostAt(indexPath: indexPath)
            
        }
        return [deleteAction]
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return dataSource[indexPath.row].author.email == "luisv@gmail.com"
    }
}

//MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    //Número total de celda
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    //Configurar celda creada
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        if let cell = cell as? TweetTableViewCell {
            cell.setUpCellWidth(post: dataSource[indexPath.row])
            
        }
        return cell
    }
}
