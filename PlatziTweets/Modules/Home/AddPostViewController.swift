//
//  AddPostViewController.swift
//  PlatziTweets
//
//  Created by Luis Vargas on 10/5/20.
//  Copyright © 2020 Luis Vargas. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    //MARK: -IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    //MARK: -IBActions
    @IBAction func openCameraAction() {
        let alert = UIAlertController(title: "Cámara", message: "Selecciona una opción", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Foto", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { _ in
            self.openVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
       }
    
    @IBAction  func addPostAction() {
        uploadVideoToFirebase()
        //openVideoCamera()
        //uploadPhotoToFirebase()
    }
    @IBAction func openPreviewAction() {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        let avPlayer = AVPlayer(url: currentVideoURL)
        
        
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        //Present nos presenta nuevas pantallas de manera programatica
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    @IBAction  func dismisAction() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Properties
    private var currentVideoURL: URL?
    private var imagePicker: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoButton.isHidden = true
        
    }
    private func openVideoCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        present(imagePicker, animated: true, completion: nil)
        
    }
    private func openCamera() {
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    private func uploadPhotoToFirebase(){
        //1. Asegurarnos que la foto exista
        //2. comprimir la imagen en Data
        guard let imageSaved = previewImageView.image,
            let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
                return
        }
        SVProgressHUD.show()
        //3. configuración para guardar la foto en firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        //4. Crear referencia al storage de firebase
        let storage = Storage.storage()
        
        //5. Crear nombre de la imagen a subir
        let imageName = Int.random(in: 100...1000)
        
        //6. crear la referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "fotos-tweets/\(imageName).jpg")
        
        //7. Subir la foto a firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                DispatchQueue.main.async {
                    //Detener la carga
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        NotificationBanner(subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                    //obtener la URL de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        //imprime el string y si no (??) un string vacio
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: downloadUrl, videoUrl: nil)
                    }
                }
            }
        }
    }
    private func uploadVideoToFirebase(){
        //1. Asegurarnos que el video exista
        //2. convertir en data el video
        guard let currentVideoSavedURL = currentVideoURL,
            let videoData: Data = try? Data(contentsOf: currentVideoSavedURL) else {
                return
        }
        SVProgressHUD.show()
        //3. configuración para guardar la foto en firebase
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/mp4"
        
        //4. Crear referencia al storage de firebase
        let storage = Storage.storage()
        
        //5. Crear nombre de la imagen a subir
        let videoName = Int.random(in: 100...1000)
        
        //6. crear la referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "video-tweets/\(videoName).mp4")
        
        //7. Subir el video a firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error: Error?) in
                DispatchQueue.main.async {
                    //Detener la carga
                    SVProgressHUD.dismiss()
                    
                    if let error = error {
                        NotificationBanner(subtitle: error.localizedDescription, style: .warning).show()
                        return
                    }
                    //obtener la URL de descarga
                    folderReference.downloadURL { (url: URL?, error: Error?) in
                        //imprime el string y si no (??) un string vacio
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: nil, videoUrl: downloadUrl)
                    }
                }
            }
        }
    }
    private func savePost(imageUrl: String?, videoUrl: String?) {
        //1 crear request
        let request = PostRequest(text: postTextView.text, imageUrl: imageUrl, videoUrl: videoUrl, location: nil)
        
        //2. Inidcar carga al usuario
        SVProgressHUD.show()
        
        //3. Llamar al servicio del post
        SN.post(endpoint: Endpoints.post, model: request) { ( response: SNResultWithEntity<Post,
            ErrorResponse>) in
            //4. Cerrar el indicador de carga.
            SVProgressHUD.dismiss()
            switch response {
            case .success:
                self.dismiss(animated: true, completion: nil)
                
            case .error(let error):
                NotificationBanner(subtitle: error.localizedDescription, style: .danger).show()
            case .errorResult(let entity):
                NotificationBanner(subtitle: entity.error, style: .warning).show()
            }
            
        }
    }
}

//Los delegados siempre los implementamos en extensiones.
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Aqui vemos cuando se toma o no se toma la foto
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Cerrar selector de fotos (Cerrar camara)
        imagePicker?.dismiss(animated: true, completion: nil)
        //Capturar imagen
        if info.keys.contains(.originalImage) {
            previewImageView.isHidden = false
            //De este forma obtenemos la imagen tomada
            previewImageView.image = info[.originalImage] as? UIImage
        }
        //Aqui capturamos la URL del video
        if info.keys.contains(.mediaURL), let recordedVideoURL = (info[.mediaURL] as? URL)?.absoluteURL {
            videoButton.isHidden = false
            currentVideoURL = recordedVideoURL
        }
    }
}
