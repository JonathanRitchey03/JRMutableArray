import UIKit

class JRDrawKit: NSObject {

    var currentArray : NSMutableArray!
    var currentColor : UIColor!
    var currentItemHeight : Double!
    var currentFontHeight : Double!
    var markedRange : NSRange?
    var markedIndex : Int?
    var barStartX : Double!
    
    override init() {
        currentColor = UIColor.whiteColor()
        currentFontHeight = 8
        currentItemHeight = currentFontHeight+2
        currentArray = []
    }
    
    internal func drawIndices(xPos: Double) {
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        let textFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(CGFloat(currentFontHeight)), NSForegroundColorAttributeName: currentColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<currentArray.count {
            let y = Double(i) * currentItemHeight
            let indexString = String(i)
            indexString.drawAtPoint(CGPointMake(CGFloat(xPos), CGFloat(y)), withAttributes: textFontAttributes)
        }
    }
    
    private func objectDescription(object:AnyObject?) -> String {
        if object != nil {
            let hasDescription = object!.respondsToSelector(Selector("description"))
            return hasDescription ? object!.description : ""
        }
        return ""
    }
    
    internal func drawObjectDescriptions(xPos:Double) {
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        let textFontAttributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(CGFloat(currentFontHeight)), NSForegroundColorAttributeName: currentColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<currentArray.count {
            let y = Double(i) * currentItemHeight
            let desc = objectDescription(currentArray.objectAtIndex(i))
            desc.drawAtPoint(CGPointMake(CGFloat(xPos), CGFloat(y)), withAttributes: textFontAttributes)
        }
    }
    
    private func getDoubleForObject(object:AnyObject?)->Double? {
        if self.isObjectANumber(object) {
            return object as? Double
        }
        return nil
    }
    
    private func isObjectANumber(object:AnyObject?)->Bool {
        if object is NSNumber {
            return true
        }
        return false
    }
    
    private func arrayHasNumber()->Bool {
        for i in 0..<currentArray.count {
            let object : AnyObject? = currentArray.objectAtIndex(i)
            if self.isObjectANumber(object) {
                return true
            }
        }
        return false
    }
    
    private func getRange() -> (Double,Double) {
        var min : Double?
        var max : Double?
        if arrayHasNumber() {
            for i in 0..<currentArray.count {
                let object : AnyObject? = currentArray.objectAtIndex(i)
                let d : Double? = getDoubleForObject(object)
                if d != nil && min == nil {
                    min = d
                    max = d
                }
                if ( d < min ) { min = d }
                if ( d > max ) { max = d }
            }
        }
        if ( min == nil ) { min = 0 }
        if ( max == nil ) { max = 0 }
        return (min!,max!)
    }
    
    private func getPercentageInRange(d : Double, min : Double, max : Double) -> Double {
        let delta = max - min
        if delta != 0 {
            let percentage = d / delta
            return percentage
        }
        return 0
    }
    
    internal func drawLine(x0:Double,y0:Double,x1:Double,y1:Double) {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(CGFloat(x0), CGFloat(y0)))
        path.addLineToPoint(CGPointMake(CGFloat(x1), CGFloat(y1)))
        path.lineWidth = 0.5
        currentColor.setStroke()
        path.stroke()
    }
    
    internal func drawLines(viewWidth: Double) {
        for i in 0..<currentArray.count {
            let y = Double(i) * currentItemHeight
            drawLine(0, y0: y, x1: viewWidth, y1: y)
        }
    }

    func getStringWidth(string: NSString) -> Double {
        let size : CGSize = string.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(currentFontHeight))])
        return Double(size.width)
    }
    
    func renderArray(array:NSMutableArray, maxCount: Int, markedRange: AnyObject) -> UIImage {
        currentFontHeight = 10.0
        currentItemHeight = currentFontHeight + 2.0
        currentArray = array
        let viewWidth = 200.0
        let size = CGSizeMake(CGFloat(viewWidth),CGFloat(Double(maxCount)*currentItemHeight))
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.blackColor().setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        // .....................................................................
        //    |                        |       |
        //    | <-    indexSpace    -> | <- -> |
        //    V                                V
        //  leftMarginX                    objectDescX
        //
        let leftMarginX : Double = 2
        let lastIndexString = "\(maxCount-1)"
        let indexSpace = getStringWidth(lastIndexString) + 2
        let objectLineX = leftMarginX + indexSpace
        let objectDescX = objectLineX + 2
        currentColor = UIColor.grayColor()
        drawLines(viewWidth)
        drawLine( objectLineX, y0: 0, x1:objectLineX, y1: Double(size.height))
        currentColor = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 218.0/255.0, alpha: 0.7)
        barStartX = objectDescX
        drawBarsIfNumbers(viewWidth)
        currentColor = UIColor.whiteColor()
        drawIndices(leftMarginX)
        drawObjectDescriptions(objectDescX)
        currentColor = UIColor(red: 0.2, green: 0.2, blue: 0.7, alpha: 0.5)
        drawRange(viewWidth, markedRange:markedRange)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    internal func drawRange(viewWidth: Double, markedRange: AnyObject ) {
        if markedRange is NSRange {
            let range : NSRange = markedRange as! NSRange
            if  range.length > 0 {
                let (x0,y0) = (barStartX, Double(range.location) * currentItemHeight)
                let (x1,y1) = (viewWidth, Double(range.location + range.length) * currentItemHeight)
                let rectanglePath = UIBezierPath(roundedRect: CGRectMake(CGFloat(x0), CGFloat(y0), CGFloat(x1), CGFloat(y1)), cornerRadius: 10)
                currentColor.setFill()
                rectanglePath.fill()
            }
        }
    }
    
    internal func drawBarsIfNumbers(viewWidth: Double) {
        if arrayHasNumber() {
            var (min,max) = getRange()
            if ( min > 0 ) {
                min = 0
            }
            let width : Double = viewWidth - barStartX
            for i in 0..<currentArray.count {
                let y = Double(i) * currentItemHeight
                let barHeight : CGFloat = CGFloat(currentItemHeight - 2)
                let object : AnyObject? = currentArray.objectAtIndex(i)
                if object != nil {
                    if self.isObjectANumber(object) {
                        let d = getDoubleForObject(object)
                        var x0Line : Double = barStartX
                        if ( min < 0 ) {
                            x0Line = barStartX + getPercentageInRange(-min, min: min, max: max) * width
                        }
                        var rectPath : UIBezierPath
                        if ( d > 0 ) {
                            let posBarWidth = getPercentageInRange(d!, min: min, max: max) * width
                            rectPath = UIBezierPath(rect: CGRectMake(CGFloat(x0Line),CGFloat(y+1),CGFloat(posBarWidth),barHeight))
                        } else {
                            let negBarWidth = getPercentageInRange(-d!, min: min, max: max) * width
                            rectPath = UIBezierPath(rect: CGRectMake(CGFloat(x0Line - negBarWidth),CGFloat(y+1),CGFloat(negBarWidth),barHeight))
                        }
                        currentColor.setFill()
                        rectPath.fill()
                    }
                }
            }
        }
    }
}
