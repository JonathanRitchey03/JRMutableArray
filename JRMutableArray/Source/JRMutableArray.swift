import Foundation
import UIKit

open class JRMutableArray : NSObject {

    fileprivate var storage : NSMutableArray
    fileprivate var commandHistory : NSMutableArray
    fileprivate var queue : DispatchQueue
    fileprivate var drawKit : JRDrawKit
    fileprivate var markedRange : NSRange?
    
    public override init() {
        storage = NSMutableArray()
        commandHistory = NSMutableArray()
        queue = DispatchQueue(label: "JRMutableArray Queue", attributes: DispatchQueue.Attributes.concurrent)
        drawKit = JRDrawKit()
    }
    
    open func count() -> Int {
        var numItems = 0
        queue.sync(execute: { [weak self] in
            if self != nil {
                numItems = (self?.storage.count)!
            }
        })
        return numItems
    }
    
    open func swap(_ objectAtIndex: Int, withObjectAtIndex: Int) {
        let temp = self[objectAtIndex]
        self[objectAtIndex] = self[withObjectAtIndex]
        self[withObjectAtIndex] = temp
    }
    
    open subscript(index: Int) -> Any? {
        get {
            var value : Any? = nil
            queue.sync(execute: { [weak self] in
                value = self?.storage.object(at: index) as Any?
            })
            return value
        }
        set(newValue) {
            queue.sync(flags: .barrier, execute: { [weak self] in
                if let strongSelf = self {
                    if newValue != nil {
                        if index < strongSelf.storage.count {
                            strongSelf.storage.replaceObject(at: index, with: newValue!)
                        } else {
                            if ( index > strongSelf.storage.count ) {
                                // fill array up with NSNull.null until index
                                let topIndex = strongSelf.storage.count
                                for i in topIndex..<index {
                                    strongSelf.storage.insert(NSNull(), at: i)
                                }
                            }
                            strongSelf.storage.insert(newValue!, at: index)
                        }
                        let commandArray = NSMutableArray()
                        commandArray.add(index)
                        commandArray.add(newValue!)
                        if strongSelf.markedRange != nil {
                            commandArray.add(NSMakeRange(strongSelf.markedRange!.location, strongSelf.markedRange!.length))
                        } else {
                            commandArray.add(NSNull())
                        }
                        self?.commandHistory.add(commandArray)
                    }
                }
            })
        }
    }
    
    open func markRange(_ range:NSRange) {
        self.markedRange = NSMakeRange(range.location, range.length)
    }
    
    open func markIndex(_ index:Int?) {
        //drawKit.markedIndex = index
    }
    
    open func writeToTmp() {
        let tempArray = NSMutableArray()
        for i in 0..<commandHistory.count {
            let commandArray = commandHistory.object(at: i) as! NSMutableArray
            let index = commandArray[0] as! Int
            let object = commandArray[1]
            let markedRange = commandArray[2]
            if index < tempArray.count {
                tempArray.replaceObject(at: index, with: object)
            } else {
                tempArray.insert(object, at: index)
            }
            let image = drawKit.renderArray(tempArray,maxCount:Int(storage.count),markedRange:markedRange)
            let fileManager = FileManager.default
            let myImageData = UIImagePNGRepresentation(image)
            let path = "/tmp/myarray\(i).png"
            fileManager.createFile(atPath: path, contents: myImageData, attributes: nil)
        }
    }

    open func debugQuickLookObject() -> AnyObject? {
        var markedRange : AnyObject = NSNull()
        if let aMarkedRange = self.markedRange {
            markedRange = aMarkedRange as AnyObject
        }
        return drawKit.renderArray(storage, maxCount:Int(storage.count), markedRange:markedRange)
    }
}
