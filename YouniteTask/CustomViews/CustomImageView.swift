//
//  CustomImageView.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import Foundation
import UIKit

class CustomImageView : UIImageView{
    weak var percentageLabel: UILabel?
    func download(from url: URL,label : UILabel) {
        self.percentageLabel = label
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        
            self.percentageLabel?.isHidden = false
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
    }
}
extension CustomImageView : URLSessionDownloadDelegate
{
    
    // MARK: prepare url from string
    func getURLFromString(_ str: String) -> URL? {
        return URL(string: str)
    }
    
    
    // MARK: protocol stub for download completion tracking
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        // get downloaded data from location
        let data = readDownloadedData(of: location)
        
        // set image to imageview
        setImageToImageView(from: data)
    }
    
    // MARK: protocol stubs for tracking download progress
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percentDownloaded = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(percentDownloaded)
        DispatchQueue.main.async {
            self.percentageLabel?.text = "\(Int(percentDownloaded * 100))%"
        }
    }
    
    // MARK: set image to image view
    func setImageToImageView(from data: Data?) {
        guard let imageData = data else { return }
        guard let image = getUIImageFromData(imageData) else { return }
        
        DispatchQueue.main.async {
            self.percentageLabel?.isHidden = true
            self.image = image
        }
    }
    func getUIImageFromData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    // MARK: read downloaded data
    func readDownloadedData(of url: URL) -> Data? {
        do {
            let reader = try FileHandle(forReadingFrom: url)
            let data = reader.readDataToEndOfFile()
            
            return data
        } catch {
            print(error)
            return nil
        }
    }
}
