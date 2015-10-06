import Foundation
import UIKit

public class JRMutableArray : NSObject {

    private var storage : NSMutableArray
    private var queue : dispatch_queue_t
    
    override init() {
        storage = NSMutableArray()
        queue = dispatch_queue_create("JRMutableArray Queue", DISPATCH_QUEUE_CONCURRENT)
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
    
    subscript(index: Int) -> AnyObject? {
        get {
            var value : AnyObject? = nil
            dispatch_async(queue, { [weak self] in
                value = self?.storage.objectAtIndex(index)
            })
            return value
        }
        set(newValue) {
            dispatch_barrier_sync(queue, { [weak self] in
                if newValue != nil {
                    if index < self?.storage.count {
                        self?.storage.replaceObjectAtIndex(index, withObject: newValue!)
                    } else {
                        self?.storage.insertObject(newValue!, atIndex: index)
                    }
                }
            })
        }
    }
    
    func debugQuickLookObject() -> AnyObject? {
        let itemHeight : Double = 12
        let viewWidth : Double = 600
        let drawKit = JRDrawKit()
        drawKit.currentArray = storage
        drawKit.currentItemHeight = itemHeight
        let size = CGSizeMake(CGFloat(viewWidth),CGFloat(Double(self.storage.count)*itemHeight))
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.blackColor().setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let leftMarginX : Double = 5
        let indexObjectDividerX : Double = 40
        let indexObjectDividerMarginX : Double = 5
        let objectGraphDividerX : Double = 70
        drawKit.currentColor = UIColor.grayColor()
        drawKit.drawLines(viewWidth)
        drawKit.drawLine(indexObjectDividerX - indexObjectDividerMarginX, y0: 0,
                         x1: indexObjectDividerX - indexObjectDividerMarginX, y1: Double(size.height))
        drawKit.drawLine(objectGraphDividerX, y0: 0,
                         x1: objectGraphDividerX, y1: Double(size.height))
        drawKit.currentColor = UIColor.blueColor()
        drawKit.drawBarsIfNumbers(objectGraphDividerX, viewWidth: viewWidth)
        drawKit.currentColor = UIColor.whiteColor()
        drawKit.drawIndices(leftMarginX)
        drawKit.drawObjectDescriptions(indexObjectDividerX)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }    
}

/****************	Mutable Array		****************/
//public class NSMutableArray : NSArray {
//    
//    public func addObject(anObject: AnyObject)
//    public func insertObject(anObject: AnyObject, atIndex index: Int)
//    public func removeLastObject()
//    public func removeObjectAtIndex(index: Int)
//    public func replaceObjectAtIndex(index: Int, withObject anObject: AnyObject)
//    public init()
//    public init(capacity numItems: Int)
//    public init?(coder aDecoder: NSCoder)
//}
//
//extension NSMutableArray {
//    
//    public func addObjectsFromArray(otherArray: [AnyObject])
//    public func exchangeObjectAtIndex(idx1: Int, withObjectAtIndex idx2: Int)
//    public func removeAllObjects()
//    public func removeObject(anObject: AnyObject, inRange range: NSRange)
//    public func removeObject(anObject: AnyObject)
//    public func removeObjectIdenticalTo(anObject: AnyObject, inRange range: NSRange)
//    public func removeObjectIdenticalTo(anObject: AnyObject)
//    
//    public func removeObjectsInArray(otherArray: [AnyObject])
//    public func removeObjectsInRange(range: NSRange)
//    public func replaceObjectsInRange(range: NSRange, withObjectsFromArray otherArray: [AnyObject], range otherRange: NSRange)
//    public func replaceObjectsInRange(range: NSRange, withObjectsFromArray otherArray: [AnyObject])
//    public func setArray(otherArray: [AnyObject])
//    public func sortUsingFunction(compare: @convention(c) (AnyObject, AnyObject, UnsafeMutablePointer<Void>) -> Int, context: UnsafeMutablePointer<Void>)
//    public func sortUsingSelector(comparator: Selector)
//    
//    public func insertObjects(objects: [AnyObject], atIndexes indexes: NSIndexSet)
//    public func removeObjectsAtIndexes(indexes: NSIndexSet)
//    public func replaceObjectsAtIndexes(indexes: NSIndexSet, withObjects objects: [AnyObject])
//    public subscript (idx: Int) -> AnyObject
//    
//    @available(iOS 4.0, *)
//    public func sortUsingComparator(cmptr: NSComparator)
//    @available(iOS 4.0, *)
//    public func sortWithOptions(opts: NSSortOptions, usingComparator cmptr: NSComparator)
//}
//
//extension NSMutableArray {
//    
//    public convenience init?(contentsOfFile path: String)
//    public convenience init?(contentsOfURL url: NSURL)
//}
