import XCTest
@testable import JRMutableArray

class JRMutableArrayTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSequentialIntInsertion() {
        let array = JRMutableArray()
        for i in 0...100 {
            array[i] = i
        }
        for i in 0...100 {
            let num = array[i]
            if num is Int {
                XCTAssertEqual(num as? Int, i, "numbers inserted must match")
            } else {
                XCTAssert(false, "expected numbers to be ints")
            }
        }
        XCTAssert(array.debugQuickLookObject() != nil, "quicklook should return something")
    }

    func testSequentialDoubleInsertion() {
        let array = JRMutableArray()
        for i in 0...100 {
            array[i] = Double(i) * 3.14
        }
        for i in 0...100 {
            let num = array[i]
            if num is Double {
                XCTAssertEqual(num as? Double, Double(i) * 3.14, "numbers inserted must match")
            } else {
                XCTAssert(false, "expected numbers to be doubles")
            }
        }
        XCTAssert(array.debugQuickLookObject() != nil, "quicklook should return something")
    }

    func testSequentialFloatInsertion() {
        let array = JRMutableArray()
        for i in 0...100 {
            array[i] = Float(i) * 3.14
        }
        for i in 0...100 {
            let num = array[i]
            if num is Float {
                XCTAssertEqual(num as? Float, Float(i) * 3.14, "numbers inserted must match")
            } else {
                XCTAssert(false, "expected numbers to be floats")
            }
        }
        XCTAssert(array.debugQuickLookObject() != nil, "quicklook should return something")
    }

    func testSparseInsertion() {
        let array = JRMutableArray()
        for i in stride(from: 2, to: 100, by: 7) {
            array[i] = i
        }
        for i in 0..<array.count() {
            if (i - 2) % 7 == 0 {
                let num = array[i]
                if num is Int {
                    XCTAssertEqual(num as? Int, i, "numbers inserted must match")
                } else {
                    XCTAssert(false, "expected numbers to be ints")
                }
            } else {
                if array[i] is NSNull {
                    // ok
                } else {
                    XCTAssert(false, "empty cells should be NSNull")
                }
            }
        }
        XCTAssert(array.debugQuickLookObject() != nil, "quicklook should return something")
    }

    func testQuicksort() {
        let array = JRMutableArray()
        let size = 50
        for i in 0..<size {
            array[i] = -10 + Int(arc4random() % 30)
        }
        self.quicksort(array, lo: 0, hi: array.count() - 1)
        var previous : Int = array[0] as! Int
        for i in 1..<array.count() {
            let current : Int = array[i] as! Int
            XCTAssert(previous <= current, "order must be ascending")
            previous = current
        }
    }
    
    func quicksort(_ array: JRMutableArray, lo: Int, hi: Int) {
        if lo < hi {
            array.markRange(NSMakeRange(lo,hi-lo+1))
            let p = quicksortPartition(array, lo: lo, hi: hi)
            quicksort(array,lo:lo,hi:p-1)
            quicksort(array,lo:p+1,hi:hi)
        }
    }
    
    func quicksortPartition(_ array: JRMutableArray, lo: Int, hi: Int) -> Int {
        let p : Double = array[hi] as! Double
        var i = lo
        for j in lo..<hi {
            let aj : Double = array[j] as! Double
            if aj < p {
                array.swap(i,withObjectAtIndex:j)
                i += 1
            }
        }
        array.swap(i, withObjectAtIndex: hi)
        return i
    }
}
