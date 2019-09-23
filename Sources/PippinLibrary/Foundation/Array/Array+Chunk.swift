//
//  Array+Chunk.swift
//  Pippin
//
//  Created by Andrew McKnight on 12/17/18.
//

import Foundation

public extension Array {
    func chunk(intoSubarraysOfSize subarraySize: Int) -> [[Element]] {
        guard subarraySize > 0 else { return [[Element]]() }
        var chunks = [[Element]]()
        let numChunks = count / subarraySize + (count % subarraySize > 0 ? 1 : 0)
        for chunkIdx in 0 ..< numChunks {
            var chunk = [Element]()
            let chunkStart = chunkIdx * subarraySize
            for chunkItemIdx in 0 ..< subarraySize {
                let index = chunkStart + chunkItemIdx
                guard index < self.count else { break }
                let element = self[index]
                chunk.append(element)
            }
            chunks.append(chunk)
        }
        return chunks
    }
}
