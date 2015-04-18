//
//  ViewController.swift
//  NHPageView
//
//  Created by Nathan Hegedus on 4/2/15.
//  Copyright (c) 2015 Nathan Hegedus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pageRightView: NHPageView!
    @IBOutlet weak var pageCenterView: NHPageView!
    @IBOutlet weak var pageLeftView: NHPageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var rightArray: Array <UIView> = Array()
        
        for var i = 0; i < 10; i++ {
            
            var view: UIView = UIView (frame: CGRectMake(0, 0, 200, 100))
            view.backgroundColor = UIColor.lightGrayColor()
            rightArray.insert(view, atIndex: i)
            
        }
        
        self.pageRightView.alignment = .Right
        self.pageRightView.insertSubviews(rightArray)
        
        
        
        
        var centerArray: Array <UIView> = Array()
        
        for var i = 0; i < 10; i++ {
            
            var view: UIView = UIView (frame: CGRectMake(0, 0, 200, 100))
            view.backgroundColor = UIColor.lightGrayColor()
            centerArray.insert(view, atIndex: i)
            
        }
        
        self.pageCenterView.alignment = .Center
        self.pageCenterView.insertSubviews(centerArray)

        var leftArray: Array <UIView> = Array()
        for var i = 0; i < 10; i++ {
            
            var view: UIView = UIView (frame: CGRectMake(0, 0, 200, 100))
            view.backgroundColor = UIColor.lightGrayColor()
            leftArray.insert(view, atIndex: i)
            
        }
        self.pageLeftView.alignment = .Left
        self.pageLeftView.insertSubviews(leftArray)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

