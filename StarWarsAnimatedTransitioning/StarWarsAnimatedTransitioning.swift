//
//  StarWarsAnimatedTransitioning.swift
//
//  Created by Ivan Konov on 12/18/14.
//
//The MIT License (MIT)
//
//Copyright (c) 2014-2015 Ivan Konov
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit

@objc enum StarWarsTransitionType : Int {
    case LinearRight
    case LinearLeft
    case LinearUp
    case LinearDown
    case CircularClockwise
    case CircularCounterclockwise
}

@objc enum StarWarsOperation : Int{
    case Present
    case Dismiss
}

class StarWarsAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: NSTimeInterval = 2.4
    
    var operation: StarWarsOperation = .Present
    var type: StarWarsTransitionType = .LinearRight
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        let containerView = transitionContext.containerView()
        
        var animatedLayer: CALayer!
        
        if operation == .Present {
            animatedLayer = toController?.view.layer
            
            containerView.addSubview(toController!.view)
        }
        else {
            animatedLayer = fromController!.view.layer
        }
        
        performAnimationWithLayer(animatedLayer) {
            if self.operation == .Dismiss {
                fromController!.view.removeFromSuperview()
            }
            
            transitionContext.completeTransition(true)
        }
    }
    
    private func performAnimationWithLayer(layer: CALayer, completion: () -> Void) {
        switch (type) {
        case .LinearLeft, .LinearRight, .LinearUp, .LinearDown:
            performLinearTransitionWithLayer(layer, completion: completion)
        case .CircularClockwise, .CircularCounterclockwise:
            performCircularTransitionWithLayer(layer, completion: completion)
        }
    }
    
    // MARK: Linear Animations
    
    private func maskFrameAndPositionForLinearTransitionWithLayer(layer: CALayer) -> (CGRect, CGPoint){
        var initialMaskFrame: CGRect!
        var finalPosition: CGPoint!
        
        switch type {
        case .LinearRight:
            if operation == .Present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.x -= CGRectGetWidth(initialMaskFrame)
                
                finalPosition = layer.position
            }
            else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.x += CGRectGetWidth(layer.bounds)
            }
        case .LinearLeft:
            if operation == .Present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.x += CGRectGetWidth(initialMaskFrame)
                
                finalPosition = layer.position
            }
            else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.x -= CGRectGetWidth(layer.bounds)
            }
        case .LinearUp:
            if operation == .Present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.y += CGRectGetHeight(layer.bounds)
                
                finalPosition = layer.position
            }
            else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.y -= CGRectGetHeight(layer.bounds)
            }
        case .LinearDown:
            if operation == .Present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.y -= CGRectGetHeight(layer.bounds)
                
                finalPosition = layer.position
            }
            else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.y += CGRectGetHeight(layer.bounds)
            }
        default:
            println("Something went wrong! Mask frame and position calculations should not be made for non-linear transition types.")
            
            initialMaskFrame = CGRectZero;
            finalPosition = CGPointZero;
        }
        
        return (initialMaskFrame, finalPosition)
    }
    
    private func performLinearTransitionWithLayer(layer: CALayer, completion: () -> Void) {
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.whiteColor().CGColor
        layer.mask = maskLayer
        
        let (initalFrame, finalPosition) = maskFrameAndPositionForLinearTransitionWithLayer(layer)
        maskLayer.frame = initalFrame
        
        CATransaction.setCompletionBlock {
            layer.mask = nil
            
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.fromValue = NSValue(CGPoint: layer.mask.position)
        animation.toValue = NSValue(CGPoint: finalPosition)
        animation.timingFunction = CAMediaTimingFunction(name: kCAAnimationLinear)
        
        layer.mask.addAnimation(animation, forKey: "position")
        
        layer.mask.position = finalPosition
    }
    
    // MARK: Circular Animations
    
    private func anglesAndDirectionForCircularTransition() -> (Float, Float, Bool) {
        let start: Float
        let end: Float
        let clockwise: Bool
        
        switch(type) {
        case .CircularClockwise:
            clockwise = true
            
            if operation == .Present {
                start = 0
                end = 360
            }
            else {
                start = 0
                end = 360
            }
        case .CircularCounterclockwise:
            clockwise = false
            start = 360
            end = 0
        default:
            println("Something went wrong! No angle calculations should be made for non-circular transition types.")
            
            clockwise = true
            start = 0
            end = 0
        }

        return (start, end, clockwise)
    }
    
    private func performCircularTransitionWithLayer(layer: CALayer, completion: () -> Void) {
        let maskLayer = CircularMaskLayer()
        
        let msk = CAShapeLayer()
        msk.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        msk.path = UIBezierPath(ovalInRect: msk.bounds).CGPath
        msk.backgroundColor = UIColor.blackColor().CGColor
        
//        msk.path = UIBezierPath
//        maskLayer.frame = layer.bounds
        
        if operation == .Present {
            maskLayer.fillColor = UIColor.whiteColor()
        }
        else {
            maskLayer.fillColor = UIColor(white: 1, alpha: 1)
        }
        
       // layer.addSublayer(maskLayer)
        layer.mask = msk
        
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            layer.mask = nil
            
           // maskLayer.removeFromSuperlayer()
            
            completion()
        }
        
        let (startAngle, endAngle, clockwise) = anglesAndDirectionForCircularTransition()
        
        maskLayer.clockwise = clockwise
        maskLayer.startAngle = startAngle
        
        if operation == .Present {
            maskLayer.fillColor = UIColor.whiteColor()
        }
        else {
            maskLayer.fillColor = UIColor.clearColor()
        }
        
        let animation = CABasicAnimation(keyPath: "endAngle")
        animation.duration = duration
        animation.fromValue = NSNumber(float: startAngle)
        animation.toValue = NSNumber(float: endAngle)
        animation.timingFunction = CAMediaTimingFunction(name: kCAAnimationLinear)
        
       // maskLayer.addAnimation(animation, forKey: "endAngle")
        
        maskLayer.endAngle = endAngle
    }
}

class CircularMaskLayer: CALayer {
    var startAngle: Float = 0.0
    var endAngle: Float = 360.0
    var clockwise: Bool = true
    var fillColor: UIColor = UIColor(white: 1, alpha: 1)
    
    func degreesToRadians(angle: Float) -> Float {
        return angle * Float(M_PI) / 180.0
    }
    
    override func drawInContext(ctx: CGContext!) {
        let center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
        let radius = sqrt((center.x * center.x) + (center.y * center.y))
        
        let path = UIBezierPath()
        path.moveToPoint(center)
        path.addLineToPoint(CGPointMake(center.x + CGFloat(radius) * CGFloat(cosf(degreesToRadians(startAngle))), center.y + CGFloat(radius) * CGFloat(sinf(degreesToRadians(startAngle)))));
        path.addArcWithCenter(center, radius: radius, startAngle: CGFloat(degreesToRadians(startAngle)), endAngle: CGFloat(degreesToRadians(endAngle)), clockwise: clockwise)
        path.closePath()
        
        CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor);
        CGContextBeginPath(ctx)
        CGContextAddPath(ctx, path.CGPath)
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        println("draw")
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if key == "startAngle" || key == "endAngle" {
                    println("display")
            
            return true
        }
        
        return super.needsDisplayForKey(key)
    }
}