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


class JRDrawKit {

    var currentArray : NSMutableArray!
    var markedRange : NSRange?
    var markedIndex : Int?
    
    init() {
        currentArray = []
    }
    
    class Properties {
        var currentColor = UIColor.white
        var currentItemHeight: Double = 8
        var currentFontHeight: Double = 10
        var barStartX: Double = 0
        func getStringWidth(_ string: NSString) -> Double {
            let size : CGSize = string.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: CGFloat(currentFontHeight))])
            return Double(size.width)
        }
    }
    let properties = Properties()
    
    class Utils {
        fileprivate func isObjectANumber(_ object:AnyObject?)->Bool {
            return object is NSNumber
        }
        fileprivate func getPercentageInRange(_ d : Double, min : Double, max : Double) -> Double {
            let delta = max - min
            if delta != 0 {
                let percentage = d / delta
                return percentage
            }
            return 0
        }
        fileprivate func getDoubleForObject(_ object:AnyObject?)->Double? {
            if self.isObjectANumber(object) {
                if let aInt = object as? Int {
                    return Double(aInt)
                } else if let aDouble = object as? Double {
                    return aDouble
                }
                return nil
            }
            return nil
        }
    }
    let utils = Utils()
    
    internal func drawIndices(_ xPos: Double) {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        let textFontAttributes: [String: Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(properties.currentFontHeight)), NSForegroundColorAttributeName: properties.currentColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<currentArray.count {
            let y = Double(i) * properties.currentItemHeight
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
        let textFontAttributes: [String: Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(properties.currentFontHeight)), NSForegroundColorAttributeName: properties.currentColor, NSParagraphStyleAttributeName: paragraphStyle]
        for i in 0..<currentArray.count {
            let y = Double(i) * properties.currentItemHeight
            let desc = objectDescription(currentArray.object(at: i) as AnyObject?)
            desc.draw(at: CGPoint(x: CGFloat(xPos), y: CGFloat(y)), withAttributes: textFontAttributes)
        }
    }
    
    fileprivate func arrayHasNumber()->Bool {
        for i in 0..<currentArray.count {
            let object : AnyObject? = currentArray.object(at: i) as AnyObject?
            if utils.isObjectANumber(object) {
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
                let d : Double? = utils.getDoubleForObject(object)
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
    
    internal func drawLine(_ x0:Double,y0:Double,x1:Double,y1:Double) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: CGFloat(x0), y: CGFloat(y0)))
        path.addLine(to: CGPoint(x: CGFloat(x1), y: CGFloat(y1)))
        path.lineWidth = 0.5
        properties.currentColor.setStroke()
        path.stroke()
    }
    
    internal func drawLines(_ viewWidth: Double) {
        for i in 0..<currentArray.count {
            let y = Double(i) * properties.currentItemHeight
            drawLine(0, y0: y, x1: viewWidth, y1: y)
        }
    }
    
    func renderArray(_ array:NSMutableArray, maxCount: Int, markedRange: Any) -> UIImage {
        properties.currentFontHeight = 10.0
        properties.currentItemHeight = properties.currentFontHeight + 2.0
        currentArray = array
        let viewWidth = 200.0
        let size = CGSize(width: CGFloat(viewWidth),height: CGFloat(Double(maxCount)*properties.currentItemHeight))
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
        let indexSpace = properties.getStringWidth(lastIndexString as NSString) + 2
        let objectLineX = leftMarginX + indexSpace
        let objectDescX = objectLineX + 2
        properties.currentColor = UIColor.gray
        drawLines(viewWidth)
        drawLine( objectLineX, y0: 0, x1:objectLineX, y1: Double(size.height))
        properties.currentColor = UIColor(red: 106.0/255.0, green: 172.0/255.0, blue: 218.0/255.0, alpha: 0.7)
        properties.barStartX = objectDescX
        drawBarsIfNumbers(viewWidth)
        properties.currentColor = UIColor.white
        drawIndices(leftMarginX)
        drawObjectDescriptions(objectDescX)
        properties.currentColor = UIColor(red: 0.2, green: 0.2, blue: 0.7, alpha: 0.5)
        drawRange(viewWidth, markedRange:markedRange)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }

    internal func drawRange(_ viewWidth: Double, markedRange: Any ) {
        if markedRange is NSRange {
            let range : NSRange = markedRange as! NSRange
            if  range.length > 0 {
                let (x0,y0) = (properties.barStartX, Double(range.location) * properties.currentItemHeight)
                let (x1,y1) = (viewWidth, Double(range.location + range.length) * properties.currentItemHeight)
                let rectanglePath = UIBezierPath(roundedRect: CGRect(x: CGFloat(x0), y: CGFloat(y0), width: CGFloat(x1), height: CGFloat(y1)), cornerRadius: 10)
                properties.currentColor.setFill()
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
            let width : Double = viewWidth - properties.barStartX
            for i in 0..<currentArray.count {
                let y = Double(i) * properties.currentItemHeight
                let barHeight : CGFloat = CGFloat(properties.currentItemHeight - 2)
                let object : AnyObject? = currentArray.object(at: i) as AnyObject?
                if let d = utils.getDoubleForObject(object) {
                        var x0Line : Double = properties.barStartX
                        if ( min < 0 ) {
                            x0Line = properties.barStartX + utils.getPercentageInRange(-min, min: min, max: max) * width
                        }
                        var rectPath : UIBezierPath
                        if ( d > 0 ) {
                            let posBarWidth = utils.getPercentageInRange(d, min: min, max: max) * width
                            rectPath = UIBezierPath(rect: CGRect(x: CGFloat(x0Line),y: CGFloat(y+1),width: CGFloat(posBarWidth),height: barHeight))
                        } else {
                            let negBarWidth = utils.getPercentageInRange(-d, min: min, max: max) * width
                            rectPath = UIBezierPath(rect: CGRect(x: CGFloat(x0Line - negBarWidth),y: CGFloat(y+1),width: CGFloat(negBarWidth),height: barHeight))
                        }
                        properties.currentColor.setFill()
                        rectPath.fill()
                }
            }
        }
    }
}
