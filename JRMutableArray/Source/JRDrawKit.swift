import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class JRDrawKit: NSObject {

    var currentArray : NSMutableArray!
    var currentColor : UIColor!
    var currentItemHeight : Double!
    var currentFontHeight : Double!
    var markedRange : NSRange?
    var markedIndex : Int?
    var barStartX : Double!
    
    override init() {
        currentColor = UIColor.white
        currentFontHeight = 8
        currentItemHeight = currentFontHeight+2
        currentArray = []
    }
    
    internal func drawIndices(_ xPos: Double) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        let textFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(currentFontHeight)), NSForegroundColorAttributeName: currentColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<currentArray.count {
            let y = Double(i) * currentItemHeight
            let indexString = String(i)
            indexString.draw(at: CGPoint(x: CGFloat(xPos), y: CGFloat(y)), withAttributes: textFontAttributes)
        }
    }
    
    fileprivate func objectDescription(_ object:AnyObject?) -> String {
        if object != nil {
            let hasDescription = object!.responds(to: #selector(getter: NSObjectProtocol.description))
            return hasDescription ? object!.description : ""
        }
        return ""
    }
    
    internal func drawObjectDescriptions(_ xPos:Double) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        let textFontAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(currentFontHeight)), NSForegroundColorAttributeName: currentColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<currentArray.count {
            let y = Double(i) * currentItemHeight
            let desc = objectDescription(currentArray.object(at: i) as AnyObject?)
            desc.draw(at: CGPoint(x: CGFloat(xPos), y: CGFloat(y)), withAttributes: textFontAttributes)
        }
    }
    
    fileprivate func getDoubleForObject(_ object:AnyObject?)->Double? {
        if self.isObjectANumber(object) {
            return object as? Double
        }
        return nil
    }
    
    fileprivate func isObjectANumber(_ object:AnyObject?)->Bool {
        if object is NSNumber {
            return true
        }
        return false
    }
    
    fileprivate func arrayHasNumber()->Bool {
        for i in 0..<currentArray.count {
            let object : AnyObject? = currentArray.object(at: i) as AnyObject?
            if self.isObjectANumber(object) {
                return true
            }
        }
        return false
    }
    
    fileprivate func getRange() -> (Double,Double) {
        var min : Double?
        var max : Double?
        if arrayHasNumber() {
            for i in 0..<currentArray.count {
                let object : AnyObject? = currentArray.object(at: i) as AnyObject?
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
    
    fileprivate func getPercentageInRange(_ d : Double, min : Double, max : Double) -> Double {
        let delta = max - min
        if delta != 0 {
            let percentage = d / delta
            return percentage
        }
        return 0
    }
    
    internal func drawLine(_ x0:Double,y0:Double,x1:Double,y1:Double) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(x0), y: CGFloat(y0)))
        path.addLine(to: CGPoint(x: CGFloat(x1), y: CGFloat(y1)))
        path.lineWidth = 0.5
        currentColor.setStroke()
        path.stroke()
    }
    
    internal func drawLines(_ viewWidth: Double) {
        for i in 0..<currentArray.count {
            let y = Double(i) * currentItemHeight
            drawLine(0, y0: y, x1: viewWidth, y1: y)
        }
    }

    func getStringWidth(_ string: NSString) -> Double {
        let size : CGSize = string.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(currentFontHeight))])
        return Double(size.width)
    }
    
    func renderArray(_ array:NSMutableArray, maxCount: Int, markedRange: Any) -> UIImage {
        currentFontHeight = 10.0
        currentItemHeight = currentFontHeight + 2.0
        currentArray = array
        let viewWidth = 200.0
        let size = CGSize(width: CGFloat(viewWidth),height: CGFloat(Double(maxCount)*currentItemHeight))
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.black.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        // .....................................................................
        //    |                        |       |
        //    | <-    indexSpace    -> | <- -> |
        //    V                                V
        //  leftMarginX                    objectDescX
        //
        let leftMarginX : Double = 2
        let lastIndexString = "\(maxCount-1)"
        let indexSpace = getStringWidth(lastIndexString as NSString) + 2
        let objectLineX = leftMarginX + indexSpace
        let objectDescX = objectLineX + 2
        currentColor = UIColor.gray
        drawLines(viewWidth)
        drawLine( objectLineX, y0: 0, x1:objectLineX, y1: Double(size.height))
        currentColor = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 218.0/255.0, alpha: 0.7)
        barStartX = objectDescX
        drawBarsIfNumbers(viewWidth)
        currentColor = UIColor.white
        drawIndices(leftMarginX)
        drawObjectDescriptions(objectDescX)
        currentColor = UIColor(red: 0.2, green: 0.2, blue: 0.7, alpha: 0.5)
        drawRange(viewWidth, markedRange:markedRange)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    internal func drawRange(_ viewWidth: Double, markedRange: Any ) {
        if markedRange is NSRange {
            let range : NSRange = markedRange as! NSRange
            if  range.length > 0 {
                let (x0,y0) = (barStartX, Double(range.location) * currentItemHeight)
                let (x1,y1) = (viewWidth, Double(range.location + range.length) * currentItemHeight)
                let rectanglePath = UIBezierPath(roundedRect: CGRect(x: CGFloat(x0!), y: CGFloat(y0), width: CGFloat(x1), height: CGFloat(y1)), cornerRadius: 10)
                currentColor.setFill()
                rectanglePath.fill()
            }
        }
    }
    
    internal func drawBarsIfNumbers(_ viewWidth: Double) {
        if arrayHasNumber() {
            var (min,max) = getRange()
            if ( min > 0 ) {
                min = 0
            }
            let width : Double = viewWidth - barStartX
            for i in 0..<currentArray.count {
                let y = Double(i) * currentItemHeight
                let barHeight : CGFloat = CGFloat(currentItemHeight - 2)
                let object : AnyObject? = currentArray.object(at: i) as AnyObject?
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
                            rectPath = UIBezierPath(rect: CGRect(x: CGFloat(x0Line),y: CGFloat(y+1),width: CGFloat(posBarWidth),height: barHeight))
                        } else {
                            let negBarWidth = getPercentageInRange(-d!, min: min, max: max) * width
                            rectPath = UIBezierPath(rect: CGRect(x: CGFloat(x0Line - negBarWidth),y: CGFloat(y+1),width: CGFloat(negBarWidth),height: barHeight))
                        }
                        currentColor.setFill()
                        rectPath.fill()
                    }
                }
            }
        }
    }
}
