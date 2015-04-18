//
//  NHPageView.swift
//  NHPageView
//
//  Created by Nathan Hegedus on 4/2/15.
//  Copyright (c) 2015 Nathan Hegedus. All rights reserved.
//

import UIKit

enum Alignment {
    
    case Right
    case Center
    case Left
    
}

@objc protocol PageViewDelegate {
    
    func pageViewItemSize(pageView: NHPageView) -> CGSize
    func pageViewDidScroll(pageView: NHPageView) -> Void
    func pageViewCurrentItemIndexDidChange(pageView: NHPageView) -> Void
    func pageViewWillBeginDragging(pageView: NHPageView) -> Void
    func pageViewDidEndDragging(pageView: NHPageView, willDecelerate decelarete:Bool) -> Void
    func pageViewWillBeginDecelarating(pageView: NHPageView) -> Void
    func pageViewDidEndDecelerating(pageView: NHPageView) -> Void
    func pageViewDidEndScrollingAnimation(pageView: NHPageView) -> Void
    func pageView(pageView: NHPageView, shouldSelectItemAtIndex index: NSInteger) -> Bool
    func pageView(pageView: NHPageView, didSelectItemAtIndex index: NSInteger) -> Void

}

class NHPageView: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
    }


    // MARK: - Public Properties
    
    var delegate: PageViewDelegate?
    var scrollEnabled: Bool = true
    var pagingEnabled: Bool = true
    var delaysContentTouches: Bool = true
    var bounces: Bool = true
    var itemsPerPage: Int = 1;
    var truncateFinalPage: Bool = false
    var defersItemViewLoading: Bool = false
    var vertical: Bool = false
    var decelerationRate: CGFloat?
    var scrollOffset: CGFloat?
    var currentIndexItem: Int?
    var numberOfItems: Int?
    var itemSize: CGSize?
    var itemsQueueArray: NSMutableArray = NSMutableArray()
    var alignment: Alignment = .Center
    var distanceBetweenViews: CGFloat = 20
    
    
    
    // MARK: - Private Properties
    
    private var scrollView: UIScrollView!
    private var itensViewDict: NSMutableDictionary!
    private var previousIndexItem: Int!
    private var previousContentOffset: CGPoint!
    
    
    
    // MARK: - Public Methods
    
    
    func insertSubviews(viewsArray: Array<UIView>) {
        
        self.configureView()
        
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        self.itensViewDict = NSMutableDictionary()
        
        self.numberOfItems = viewsArray.count
   
        for var i = 0; i < self.numberOfItems; i++ {
            
            var view: UIView = viewsArray[i]
            view.tag = i
            
            view.frame.origin.x = (CGFloat(i)*self.distanceBetweenViews) + view.frame.size.width*CGFloat(i+1) + self.distanceBetweenViews
            
            self.itemsQueueArray.addObject(view)
            
            self.scrollView.addSubview(view)
            self.scrollView.contentSize = CGSizeMake(view.frame.origin.x + (view.frame.size.width * 2), self.scrollView.contentSize.height)

        }
        
        self.itemSize = self.itemsQueueArray.firstObject!.frame.size

        scrollToView(self.itemsQueueArray.firstObject as UIView)
        
    }
    
    func scrollToView(view: UIView) {
        
        switch self.alignment {
            
        case .Right:
            self.scrollToRightViewContentOffSetWithView(view)
            break
            
        case .Center:
            self.scrollToCenterViewContentOffSetWithView(view)
            break
            
        case .Left:
            self.scrollToLeftViewContentOffSetWithView(view)
            break
            
        }
        
    }

    
    // MARK: - Private Methods
    
    private func configureView() {
        
        self.scrollView = UIScrollView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        
        self.scrollView.backgroundColor = UIColor.clearColor()
        self.scrollView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.scrollView.autoresizesSubviews = true
        self.scrollView.delegate = self
        self.scrollView.delaysContentTouches = self.delaysContentTouches
        self.scrollView.bounces = self.bounces
        self.scrollView.alwaysBounceHorizontal = !self.vertical && self.bounces
        self.scrollView.alwaysBounceVertical = self.vertical && self.bounces
        self.scrollView.pagingEnabled = self.pagingEnabled
        self.scrollView.scrollEnabled = self.scrollEnabled
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.scrollsToTop = false
        self.scrollView.clipsToBounds = false
        self.scrollView.pagingEnabled = false

        self.decelerationRate = self.scrollView.decelerationRate
        self.itensViewDict = NSMutableDictionary()
        self.previousIndexItem = 0
        self.previousContentOffset = self.scrollView.contentOffset
        
        self.scrollOffset = 0.0
        self.currentIndexItem = 0
        self.numberOfItems = 0
        
        var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("didTap:"))
        tapGesture.delegate = self
        self.scrollView.addGestureRecognizer(tapGesture)
        
        self.clipsToBounds = true
        
        self.insertSubview(self.scrollView, atIndex: 0)

        
    }
    
    func didTap(tapGesture: UITapGestureRecognizer) {
        
        var point: CGPoint = tapGesture.locationInView(self.scrollView)
        
        for var i = 0; i < self.itemsQueueArray.count; i++ {
            
            if CGRectIntersectsRect(CGRectMake(point.x, point.y, 1, 1), self.itemsQueueArray.objectAtIndex(i).frame) {
                println("index: \(i)")
                self.delegate?.pageView(self, didSelectItemAtIndex: i)
                return
            }
            
        }
        
        
    }
    
    
    // MARK: - ScrollView Position Methods

    private func findFirstOrLastView() {
        
        var foundView: UIView!

        if scrollView.contentOffset.x > self.scrollView.frame.size.width {
            foundView = self.itemsQueueArray.lastObject as UIView
        }else{
            foundView = self.itemsQueueArray.firstObject as UIView
        }
        
        self.scrollToView(foundView)

    }
    
    
    private func scrollToRightView() {
        
        var viewSelected: UIView!
        
        for view in scrollView.subviews {
            
            let scrollViewRightX: CGFloat = scrollView.contentOffset.x + self.distanceBetweenViews
            let scrollFrame = CGRectMake(scrollViewRightX, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
            
            
            if CGRectIntersectsRect(view.frame, scrollFrame) {
                
                println("view: \(view)")
                
                self.scrollToRightViewContentOffSetWithView(view as UIView)
                viewSelected = view as UIView
                return
            }

        }
        
        if viewSelected == nil {
            self.findFirstOrLastView()
        }
        
    }
    
    private func scrollToRightViewContentOffSetWithView(view: UIView) {
        
        var rightPoint: CGPoint = CGPointMake(view.frame.origin.x - self.distanceBetweenViews, self.scrollView.contentOffset.y)
        self.updateScrollViewContentOffSet(rightPoint)

    }
    
    private func scrollToCenterView() {
        
        var viewSelected: UIView!

        for view in scrollView.subviews {

            let scrollViewCenterX: CGFloat = scrollView.frame.size.width/2 + scrollView.contentOffset.x
            let scrollFrame = CGRectMake(scrollViewCenterX, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
            
            
            if CGRectIntersectsRect(view.frame, scrollFrame) {
                
                self.scrollToCenterViewContentOffSetWithView(view as UIView)
                viewSelected = view as UIView
                return
            }

        }
        
        if viewSelected == nil {
            self.findFirstOrLastView()
        }
        
    }
    
    private func scrollToCenterViewContentOffSetWithView(view: UIView) {

        var centerPoint: CGPoint = CGPointMake(view.frame.origin.x - (scrollView.frame.size.width/2) + (view.frame.size.width/2), self.scrollView.contentOffset.y)
        
        self.updateScrollViewContentOffSet(centerPoint)
        
    }
    
    private func scrollToLeftView() {
        
        var viewSelected: UIView!

        for view in scrollView.subviews {

            let scrollViewLeftX: CGFloat = scrollView.contentOffset.x + self.scrollView.frame.size.width - view.frame.size.width - self.distanceBetweenViews
            let scrollFrame = CGRectMake(scrollViewLeftX, view.frame.origin.y, view.frame.size.width, view.frame.size.height)
            
            if CGRectIntersectsRect(view.frame, scrollFrame) {
                
                scrollToLeftViewContentOffSetWithView(view as UIView)
                viewSelected = view as UIView

                return
            }

        }
        
        if viewSelected == nil {
            self.findFirstOrLastView()
        }

        
    }
    
    private func scrollToLeftViewContentOffSetWithView(view: UIView) {
        
        var leftPoint: CGPoint = CGPointMake(view.frame.origin.x - self.scrollView.frame.size.width + view.frame.size.width + self.distanceBetweenViews, self.scrollView.contentOffset.y)
        
        self.updateScrollViewContentOffSet(leftPoint)
        
    }
    
    private func updateScrollViewContentOffSet(point: CGPoint) {
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.scrollView.setContentOffset(point, animated: false)
        })
        
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.delegate?.pageViewDidScroll(self)
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.delegate?.pageViewWillBeginDecelarating(self)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.pageViewDidEndDragging(self, willDecelerate: true)
        
        self.delegate?.pageViewWillBeginDecelarating(self)
        switch self.alignment {
            
        case .Right:
            self.scrollToRightView()
            break
            
        case .Center:
            self.scrollToCenterView()
            break
            
        case .Left:
            self.scrollToLeftView()
            break
            
        }

    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
                
            
    }
    
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {

        switch self.alignment {
            
        case .Right:
            self.scrollToRightView()
            break
            
        case .Center:
            self.scrollToCenterView()
            break
            
        case .Left:
            self.scrollToLeftView()
            break
            
        }

    }
    

}
