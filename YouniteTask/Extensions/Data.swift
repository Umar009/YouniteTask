//
//  Data.swift
//  YouniteTask
//
//  Created by The Mac Store on 19/06/2022.
//

import Foundation

extension Data
{
    func getChunks() -> [Data]
    {
        let dataLen = self.count
        let chunkSize = (102400) // MB
        let fullChunks = Int(dataLen / chunkSize)
        let totalChunks = fullChunks + (dataLen % 1024 != 0 ? 1 : 0)
        
        var chunks:[Data] = [Data]()
        for chunkCounter in 0..<totalChunks {
            var chunk:Data
            let chunkBase = chunkCounter * chunkSize
            var diff = chunkSize
            if(chunkCounter == totalChunks - 1) {
                diff = dataLen - chunkBase
            }
            
            let range:Range<Data.Index> = (chunkBase..<(chunkBase + diff))
            chunk = self.subdata(in: range)
            chunks.append(chunk)
        }
        return chunks
    }
}
