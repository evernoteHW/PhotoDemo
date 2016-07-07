//
//  DemoScrollView.swift
//  PhotoDemo
//
//  Created by WeiHu on 7/7/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

import UIKit

class DemoScrollView: UIScrollView {
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
extension DemoScrollView{
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let point: CGPoint = touch?.locationInView(self) ?? CGPointZero
        print(point)
//        self.nextResponder()?.touchesBegan(touches, withEvent: event)
//        super.touchesBegan(touches, withEvent: event)
        
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
//        self.nextResponder()?.touchesMoved(touches, withEvent: event)
//        super.touchesMoved(touches, withEvent: event)
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
//        self.nextResponder()?.touchesEnded(touches, withEvent: event)
//        super.touchesMoved(touches, withEvent: event)
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        
//        self.nextResponder()?.touchesCancelled(touches, withEvent: event)
//        super.touchesMoved(touches!, withEvent: event)
    }
}
