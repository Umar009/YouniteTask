//
//  HomeViewController.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import UIKit

protocol HomeViewControllerProtocol: AnyObject {
    func showMessage(message : String)
}
class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var cvCollectionView: UICollectionView!
    @IBOutlet weak var btnStartDownload: UIButton!
    @IBOutlet weak var btnReceive: UIButton!
    
    var presenter: HomeViewPresenterProtocol?
    let webSocket = SwiftWebSocketClient.shared
    var urls = [String]()
    var ipAddress =  "192.168.100.177"
    var port = "8080"
    var selectedImageData : Data?
    
    
    @IBAction func actionBtnReceivePhotos(_ sender: Any) {
        self.navigationController?.pushViewController(ReceiveViewRouter.setupModule(), animated: true)
    }
    @IBAction func actionBtnStartDownload(_ sender: Any) {
        if urls.count == 0
        {
            urls.append("https://firebasestorage.googleapis.com/v0/b/heylinko.appspot.com/o/banners%2F1654321606630?alt=media&token=2bf88b7f-5fd1-4208-b930-cd1f907bdb0f")
            
            
            urls.append("https://firebasestorage.googleapis.com/v0/b/heylinko.appspot.com/o/banners%2F1655268012174?alt=media&token=02acdd01-3fe9-45fd-b423-35317300fa8d")
            urls.append("https://firebasestorage.googleapis.com/v0/b/heylinko.appspot.com/o/stores%2F7miBYSYZ0ZQef81bBM6VtUGATJi2%2F1653297200320?alt=media&token=52c4e0c7-e6b4-4569-bff6-5b865bba15b6")
            
            cvCollectionView.reloadData()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HomeCollectionViewCell.RegisterCell(collectionView: cvCollectionView)
        
        cvCollectionView.dataSource = self
        cvCollectionView.delegate = self
        btnStartDownload.layer.cornerRadius = 4
        btnReceive.layer.cornerRadius = 4
    }
    

}
extension HomeViewController :HomeViewControllerProtocol
{
    func showMessage(message : String)
    {
        DispatchQueue.main.async {
            self.view.hideToast()
            self.view.makeToast(message)
        }
    }
}

extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urls.count
    }
    func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width/2 - 5, height: 300)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = HomeCollectionViewCell.getCell(collectionView: collectionView, indexPath: indexPath)
        
        cell.downloadImage(url: urls[indexPath.row])
        
        return  cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? HomeCollectionViewCell
        if let data = cell?.imImageView.image?.pngData()
        {
            self.selectedImageData = data
            showAlertView()
            return
        }
        self.view.makeToast("Please wait Image is downloading")
    }
}
extension HomeViewController
{
    func showAlertView(title : String = "Send Photo ?")
    {
        var tfIP = UITextField()
        var tfPort = UITextField()
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        alert.addTextField { ipTextField in
            ipTextField.placeholder = "Input IpAddress"
            ipTextField.text = self.ipAddress
            tfIP = ipTextField
            
        }
        alert.addTextField { portTextField in
            portTextField.placeholder = "Input Port"
            portTextField.text = self.port
            portTextField.keyboardType = .numberPad
            tfPort = portTextField
            
        }
        
        let action = UIAlertAction(title: "Connect", style: .default) { action in
            self.ipAddress = tfIP.text ?? ""
            self.port = tfPort.text ?? ""
            if !self.ipAddress.isValidIpAddress
            {
                self.showAlertView(title: "Wrong Ip Address ?")
                return
            }
            self.presenter?.sendData(ipAddress: self.ipAddress, port: self.port, data: self.selectedImageData)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .default) { action in
        }
        
        alert.addAction(cancel)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}
