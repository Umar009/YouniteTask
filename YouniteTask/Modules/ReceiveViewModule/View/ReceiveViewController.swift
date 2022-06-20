//
//  ReceiveViewController.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import UIKit

protocol ReceiveViewControllerProtocol: AnyObject {
    func showMessage(message : String)
    func connectionCallBack(response : ServerConnectionResponse)
    func receiveImagePackage(imageData : ImageDataResponse)
}
class ReceiveViewController: UIViewController {
    
    
    static var connected = false
    
    @IBOutlet weak var cvCollectionView: UICollectionView!
    @IBOutlet weak var btnRestart: UIButton!
    
    var presenter: ReceiveViewPresenterProtocol?
    var urls = [String]()
    var downloadedImages = [ReceiveImageModel]()
    var selectedImageData : Data?
    
    
    @IBAction func actionBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func actionBtnRestartServer(_ sender: Any) {
        self.presenter?.startServer()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        HomeCollectionViewCell.RegisterCell(collectionView: cvCollectionView)
        
        cvCollectionView.dataSource = self
        cvCollectionView.delegate = self
        btnRestart.layer.cornerRadius = 4
//        cvCollectionView.isUserInteractionEnabled = false
        if !ReceiveViewController.connected
        {
            self.presenter?.startServer()
        }
        self.btnRestart.isEnabled = false
        self.btnRestart.setTitle("Server Ready", for: .normal)
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter?.stopServer()
    }
    

}
extension ReceiveViewController :ReceiveViewControllerProtocol
{
    func showMessage(message : String)
    {
        DispatchQueue.main.async {
            self.view.hideToast()
            self.view.makeToast(message)
        }
    }
    
    func connectionCallBack(response : ServerConnectionResponse)
    {
        DispatchQueue.main.async {
            self.btnRestart.isEnabled = response.connectionType == .failed
            
            self.btnRestart.setTitle(self.btnRestart.isEnabled ? "Start Server" : "Server Ready", for: .normal)
            self.showMessage(message: response.message)
            ReceiveViewController.connected = !self.btnRestart.isEnabled
        }
    }
    func receiveImagePackage(imageData : ImageDataResponse)
    {
        DispatchQueue.main.async {
            if imageData.index == 0
            {
                self.downloadedImages.append(ReceiveImageModel())
                
            }
            if let base64Data = Data(base64Encoded: imageData.base64)
            {
                let percentDownloaded : Float = Float(imageData.index + 1) / Float(imageData.length)
                self.downloadedImages[self.downloadedImages.count - 1].update(percentage: Int(percentDownloaded * 100), data: base64Data)
                
            }
            self.cvCollectionView.reloadData()
        }
    }
}

extension ReceiveViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return downloadedImages.count
    }
    func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width/2 - 5, height: 300)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = HomeCollectionViewCell.getCell(collectionView: collectionView, indexPath: indexPath)
        cell.lbPercentage.text = "\(downloadedImages[indexPath.row].percentage)%"
        cell.imImageView.image = UIImage(data: downloadedImages[indexPath.row].imageDate)
        
        return  cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
extension ReceiveViewController
{
}
