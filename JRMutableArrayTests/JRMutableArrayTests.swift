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
                XCTAssert(false, "expected numbers to be ints")
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
                XCTAssert(false, "expected numbers to be ints")
            }
        }
        XCTAssert(array.debugQuickLookObject() != nil, "quicklook should return something")
    }

    func testSparseInsertion() {
        let array = JRMutableArray()
        for var i = 2; i < 100; i += 7 {
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
        array[0] = 3
        array[1] = 1
        array[2] = 4
        array[3] = 1
        array[4] = 5
        array[5] = 9
        array[6] = 2
        array[7] = 6
        array[8] = 5
        array[9] = 3
        array[10] = 5
        array[11] = 8
        array[12] = 9
        array[13] = 7
        array[14] = 9
        array[15] = 3
        self.quicksort(array, leftIndex: 0, rightIndex: array.count() - 1)
        var previous : Int = array[0] as! Int
        for i in 1..<array.count() {
            let current : Int = array[i] as! Int
            XCTAssert(previous <= current, "order must be ascending")
            previous = current
        }
    }
    
    func quicksort(array: JRMutableArray, leftIndex: Int, rightIndex: Int) {
        if leftIndex < rightIndex {
            let p = quicksortPartition(array, leftIndex: leftIndex, rightIndex: rightIndex)
            quicksort(array,leftIndex:leftIndex,rightIndex:p-1)
            quicksort(array,leftIndex:p+1,rightIndex:rightIndex)
        }
    }
    
    func quicksortPartition(array: JRMutableArray, leftIndex: Int, rightIndex: Int) -> Int {
        let p : Double = array[leftIndex] as! Double
        var i = leftIndex+1
        for j in leftIndex+1...rightIndex {
            let aj : Double = array[j] as! Double
            if aj < p {
                let temp = array[i]
                array[i] = array[j]
                array[j] = temp
                i++
            }
        }
        let temp = array[i-1]
        array[i-1] = p
        array[leftIndex] = temp
        return i-1
    }
}
