import Foundation
import UIKit

public class JRMutableArray : NSObject {

    private var storage : NSMutableArray
    private var commandHistory : NSMutableArray
    private var queue : dispatch_queue_t
    private var drawKit : JRDrawKit
    
    override init() {
        storage = NSMutableArray()
        commandHistory = NSMutableArray()
        queue = dispatch_queue_create("JRMutableArray Queue", DISPATCH_QUEUE_CONCURRENT)
        drawKit = JRDrawKit()
    }
    
    func count() -> Int {
        var numItems = 0
        dispatch_sync(queue, { [weak self] in
            if self != nil {
                numItems = (self?.storage.count)!
            }
        })
        return numItems
    }
    
    func swap(objectAtIndex: Int, withObjectAtIndex: Int) {
        let temp = self[objectAtIndex]
        self[objectAtIndex] = self[withObjectAtIndex]
        self[withObjectAtIndex] = temp
    }
    
    subscript(index: Int) -> AnyObject? {
        get {
            var value : AnyObject? = nil
            dispatch_sync(queue, { [weak self] in
                value = self?.storage.objectAtIndex(index)
            })
            return value
        }
        set(newValue) {
            dispatch_barrier_sync(queue, { [weak self] in
                if let strongSelf = self {
                    if newValue != nil {
                        if index < strongSelf.storage.count {
                            strongSelf.storage.replaceObjectAtIndex(index, withObject: newValue!)
                        } else {
                            if ( index > strongSelf.storage.count ) {
                                // fill array up with NSNull.null until index
                                let topIndex = strongSelf.storage.count
                                for i in topIndex..<index {
                                    strongSelf.storage.insertObject(NSNull(), atIndex: i)
                                }
                            }
                            strongSelf.storage.insertObject(newValue!, atIndex: index)
                        }
                        let commandArray = NSMutableArray()
                        commandArray.addObject(index)
                        commandArray.addObject(newValue!)
                        self?.commandHistory.addObject(commandArray)
                    }
                }
            })
        }
    }
    
    func writeToTmp() {
        let tempArray = NSMutableArray()
        for i in 0..<commandHistory.count {
            let commandArray = commandHistory.objectAtIndex(i) as! NSMutableArray
            let index = commandArray[0] as! Int
            let object = commandArray[1]
            if index < tempArray.count {
                tempArray.replaceObjectAtIndex(index, withObject: object)
            } else {
                tempArray.insertObject(object, atIndex: index)
            }
            let image = drawKit.renderArray(tempArray,maxCount:Int(storage.count))
            let fileManager = NSFileManager.defaultManager()
            let myImageData = UIImagePNGRepresentation(image)
            let path = "/tmp/myarray\(i).png"
            fileManager.createFileAtPath(path, contents: myImageData, attributes: nil)
        }
    }

    func debugQuickLookObject() -> AnyObject? {
        return drawKit.renderArray(storage, maxCount:Int(storage.count))
    }
}
