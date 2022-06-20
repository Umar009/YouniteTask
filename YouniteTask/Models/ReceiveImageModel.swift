//
//  ReceiveImageModel.swift
//  YouniteTask
//
//  Created by The Mac Store on 20/06/2022.
//

import Foundation
class ReceiveImageModel
{
    var percentage : Int = 0
    var imageDate = Data()
    func update(percentage : Int,data : Data)
    {
        self.percentage = percentage
        imageDate.append(data)
    }
}
