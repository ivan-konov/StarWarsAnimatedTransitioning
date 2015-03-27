//
//  StarWarsAnimatedTransitioning.swift
//
//  Created by Ivan Konov on 12/18/14.
//
//The MIT License (MIT)
//
//Copyright (c) 2014 Ivan Konov
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
    var duration: NSTimeInterval = 0.4
    
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
        
        // decide which VC view's layer we should animate based on the operation
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
            println("Something went wrong! Mask frame and position calculations should not be done for non-linear transition type.")
            
            initialMaskFrame = CGRectZero;
            finalPosition = CGPointZero;
        }
        
        return (initialMaskFrame, finalPosition)
    }
    
    private func performLinearTransitionWithLayer(layer: CALayer, completion: () -> Void) {
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.whiteColor().CGColor // the actual color is isrrelevant; all we need is the alpha channel
        layer.mask = maskLayer
        
        let (initalFrame, finalPosition) = maskFrameAndPositionForLinearTransitionWithLayer(layer)
        maskLayer.frame = initalFrame
        
        CATransaction.setCompletionBlock {
            // clean up
            layer.mask = nil
            
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.fromValue = NSValue(CGPoint: layer.mask.position)
        animation.toValue = NSValue(CGPoint: finalPosition)
        layer.mask.addAnimation(animation, forKey: "position")
        
        // make sure the screen will not blink due to mask layer going back to it's position set in the model
        layer.mask.position = finalPosition
    }
    
    // MARK: Circular Animations
    
    private func performCircularTransitionWithLayer(layer: CALayer, completion: () -> Void) {
        let maskLayer = CircularMaskLayer()
        maskLayer.frame = layer.bounds
        layer.mask = maskLayer
  
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            // clean up
            layer.mask = nil
            
            completion()
        }
        
        let start: Float
        let end: Float
        let clockwise: Bool
        
        switch(type) {
        case .CircularClockwise:
            clockwise = true
            start = 0
            end = 360
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
        maskLayer.clockwise = clockwise
        maskLayer.startAngle = start
        
        let animation = CABasicAnimation(keyPath: "endAngle")
        animation.duration = duration
        animation.fromValue = NSNumber(float: start)
        animation.toValue = NSNumber(float: end)
        
        maskLayer.addAnimation(animation, forKey: "endAngle")
        
        // make sure the screen will not blink due to mask layer going back to it's position set in the model
        maskLayer.endAngle = end
    }
}

class CircularMaskLayer: CALayer {
    var startAngle: Float = 0.0
    var endAngle: Float = 360.0
    var clockwise: Bool = true
    
    
    func degreesToRadians(angle: Float) -> Float {
        return angle * Float(M_PI) / 180.0
    }
    
    override func drawInContext(ctx: CGContext!) {
        // Create the path
        let center = CGPointMake(bounds.size.width / 2, bounds.size.height / 2)
        let radius = sqrt((center.x * center.x) + (center.y * center.y))//min(center.x, center.y)
        
        let path = UIBezierPath()
        path.moveToPoint(center)
        path.addLineToPoint(CGPointMake(center.x + CGFloat(radius) * CGFloat(cosf(degreesToRadians(startAngle))), center.y + CGFloat(radius) * CGFloat(sinf(degreesToRadians(startAngle)))));
        path.addArcWithCenter(center, radius: radius, startAngle: CGFloat(degreesToRadians(startAngle)), endAngle: CGFloat(degreesToRadians(endAngle)), clockwise: clockwise)
        path.closePath()
        
        CGContextBeginPath(ctx)
        CGContextAddPath(ctx, path.CGPath)
        CGContextDrawPath(ctx, kCGPathFillStroke);
    }
    
    override class func needsDisplayForKey(key: String) -> Bool {
        if key == "startAngle" || key == "endAngle" {
            return true
        }
        
        return super.needsDisplayForKey(key)
    }
}