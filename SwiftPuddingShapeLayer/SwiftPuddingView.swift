//
//  SwiftPuddingView.swift
//  SwiftPuddingShapeLayer
//
//  Created by 默司 on 2016/8/2.
//  Copyright © 2016年 默司. All rights reserved.
//

import UIKit

@IBDesignable
class SwiftPuddingView: UIView {
    private var shapeLayer: CAShapeLayer!
    private var controlPointView: UIView!
    
    private var startPoint: CGPoint!
    private var originRect: CGRect!
    private var displayLink: CADisplayLink!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    func setup() {
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureDidMove(_:))))
        
        self.userInteractionEnabled = true
    }
    
    func panGestureDidMove(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            startPoint = gesture.translationInView(self)
            break
        case .Changed:
            let currentPoint = gesture.translationInView(self)
            let offset = currentPoint.y - startPoint.y
            
            let size = self.frame.size
            let height = size.height
            let width = size.width
            
            controlPointView.frame = CGRectMake(width/2-1.5, height+offset, 3, 3)
            
            updateShapeLayerPath()
            
            break
        case .Ended, .Cancelled, .Failed:
            if (displayLink == nil) {
                //此處更新畫面需要用Timer或CADisplayLink，且用DisplayLink最佳(平滑)
                displayLink = CADisplayLink(target: self, selector: #selector(updateShapeLayerPath))
                displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
            }
            
            displayLink.paused = false
            
            UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                self.controlPointView.frame = self.originRect
                
                }, completion: { (finished) in
                    if finished {
                        self.displayLink.paused = true
                    }
            })
            
            break
        default:
            break
        }
    }
    
    func updateShapeLayerPath() {
        let size = self.frame.size
        let height = size.height
        let width = size.width
        
        
        let layer = controlPointView.layer.presentationLayer() as! CALayer
        let controlPoint = CGPointMake(layer.position.x, layer.position.y)
        
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(width, 0))
        path.addLineToPoint(CGPointMake(width, height))
        path.addQuadCurveToPoint(CGPointMake(0, height), controlPoint: controlPoint)
        path.closePath()
        shapeLayer.path = path.CGPath
    }
    
    override func drawRect(rect: CGRect) {
        
        let size = rect.size
        let height = size.height
        let width = size.width
        
        shapeLayer = CAShapeLayer()
        controlPointView = UIView()
        
        shapeLayer.frame = rect
        shapeLayer.fillColor = UIColor ( red: 0.3015, green: 0.3763, blue: 0.4567, alpha: 1.0 ).CGColor
        shapeLayer.path = UIBezierPath(rect: rect).CGPath
        self.layer.addSublayer(shapeLayer)
        
        originRect = CGRectMake(width/2-1.5, height, 3, 3)
        controlPointView.frame = originRect
        controlPointView.backgroundColor = UIColor.redColor() //這邊可以設定顏色把控制點可視化/不可視化
        self.addSubview(controlPointView)
    }
    
}
