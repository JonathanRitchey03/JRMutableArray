//
//  AppDelegate.swift
//  quicksort
//
//  Created by Jonathan Ritchey on 10/7/15.
//  Copyright © 2015 Jonathan Ritchey. All rights reserved.
//

import UIKit
import JRMutableArray

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let array = JRMutableArray()
        let size = 50
        srand(0)
        for i in 0..<size {
            array[i] = -10 + Int(rand() % 30)
        }
        self.quicksort(array, lo: 0, hi: array.count() - 1)
        return true
    }

    func quicksort(array: JRMutableArray, lo: Int, hi: Int) {
        if lo < hi {
            array.markRange(NSMakeRange(lo,hi-lo+1))
            let p = quicksortPartition(array, lo: lo, hi: hi)
            quicksort(array,lo:lo,hi:p-1)
            quicksort(array,lo:p+1,hi:hi)
        }
    }

    func quicksortPartition(array: JRMutableArray, lo: Int, hi: Int) -> Int {
        let p : Double = array[hi] as! Double
        var i = lo
        for j in lo..<hi {
            let aj : Double = array[j] as! Double
            if aj < p {
                array.swap(i,withObjectAtIndex:j)
                i++
            }
        }
        array.swap(i, withObjectAtIndex: hi)
        return i
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

