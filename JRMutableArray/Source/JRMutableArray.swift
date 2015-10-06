import Foundation
import UIKit

public class JRMutableArray : NSObject {
    private var storage : NSMutableArray
    private var queue : dispatch_queue_t
    public var textColor : UIColor?
    
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
    
    private var qlWidth : CGFloat = 300.0
    private var qlLineHeight = 14
    
    func debugQuickLookObject() -> AnyObject? {
        let lineHeight = 14
        let size = CGSizeMake(300,CGFloat(self.storage.count*lineHeight))
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.blackColor().setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        drawBarsIfNumbers()
        drawIndices(UIColor.whiteColor())
        drawObjectDescriptions(CGFloat(0.2), textColor: UIColor.greenColor())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func drawIndices(textColor:UIColor) {
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(12)), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<self.count() {
            let y = i * qlLineHeight
            let string : NSString? = self.storage.objectAtIndex(i).description
            if string != nil {
                let indexString = String(i)
                indexString.drawAtPoint(CGPointMake(10, CGFloat(y)), withAttributes: textFontAttributes)
            }
        }
    }

    private func drawObjectDescriptions(xPercentage:CGFloat, textColor:UIColor) {
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        let textFontAttributes = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(12)), NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<self.count() {
            let y = i * qlLineHeight
            let string : NSString? = self.storage.objectAtIndex(i).description
            if string != nil {
                string?.drawAtPoint(CGPointMake(xPercentage * qlWidth, CGFloat(y)), withAttributes: textFontAttributes)
            }
        }
    }

    private func getDoubleForObject(object:AnyObject?)->Double {
        if object is Double || object is Float || object is Int {
            return object as! Double
        }
        return Double.NaN
    }
    
    private func arrayHasNumber()->Bool {
        for i in 0..<self.count() {
            let object : AnyObject? = self.storage.objectAtIndex(i)
            if object is Double || object is Float || object is Int {
                return true
            }
        }
        return false
    }
    
    private func getRange() -> (Double,Double) {
        var min : Double = Double.NaN
        var max : Double = Double.NaN
        if arrayHasNumber() {
            for i in 0..<self.count() {
                let object : AnyObject? = self.storage.objectAtIndex(i)
                let d : Double = getDoubleForObject(object)
                if d != Double.NaN && min.isNaN {
                    min = d
                    max = d
                }
                if ( d < min ) {
                    min = d
                }
                if ( d > max ) {
                    max = d
                }
            }
        }
        return (min,max)
    }
    
    private func getPercentageInRange(d : Double, min : Double, max : Double) -> Double {
        let delta = max - min
        let dNorm = d - min
        if delta != 0 {
            let percentage = dNorm / delta
            return percentage
        }
        return 0
    }
    
    private func drawBarsIfNumbers() {
        if arrayHasNumber() {
            var min : Double = Double.NaN
            var max : Double = Double.NaN
            (min,max) = getRange()
            for i in 0..<self.count() {
                let y = i * qlLineHeight
                let barHeight : CGFloat = CGFloat(qlLineHeight - 2)
                let object : AnyObject? = self.storage.objectAtIndex(i)
                if object != nil {
                    if object is Double || object is Float || object is Int {
                        let d = getDoubleForObject(object)
                        let barWidth = getPercentageInRange(d, min: min, max: max) * Double(qlWidth)
                        let rectPath = UIBezierPath(rect: CGRectMake(0,CGFloat(y+1),CGFloat(barWidth),barHeight))
                        UIColor.blueColor().setFill()
                        rectPath.fill()
                    }
                }
            }
        }
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
