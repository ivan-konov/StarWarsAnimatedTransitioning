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
    var duration: NSTimeInterval = 0.6
    
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
        let start: Double
        let end: Double
        let clockwise: Bool
        
        switch(type) {
        case .CircularClockwise:
            if operation == .Present {
                clockwise = true
                
                start = -M_PI_2
                end = 3 * M_PI_2
            }
            else {
                clockwise = false
                
                start = -M_PI_2
                end = -5 * M_PI_2
            }
        case .CircularCounterclockwise:
            if operation == .Present {
                clockwise = false
                
                start = -M_PI_2
                end = -5 * M_PI_2
            }
            else {
                clockwise = true
                
                start = -M_PI_2
                end = 3 * M_PI_2
            }
        default:
            println("Something went wrong! No angle calculations should be made for non-circular transition types.")
            
            clockwise = true
            start = 0
            end = 0
        }
        
        return (Float(start), Float(end), clockwise)
    }
    
    private func performCircularTransitionWithLayer(layer: CALayer, completion: () -> Void) {
        let maskLayer = CAShapeLayer()
        
        let maskWidth =  Float(CGRectGetWidth(layer.bounds))
        let maskHeight = Float(CGRectGetHeight(layer.bounds))
        
        maskLayer.frame = layer.bounds
        maskLayer.fillColor = UIColor.clearColor().CGColor
        maskLayer.strokeColor = UIColor.whiteColor().CGColor
        
        let center = CGPoint(x: CGRectGetWidth(maskLayer.bounds) / 2, y: CGRectGetHeight(maskLayer.bounds) / 2)
        let radius = sqrt((center.x * center.x) + (center.y * center.y)) / 2
        
        maskLayer.lineWidth = CGFloat(radius) * 2
        
        let (startAngle, endAngle, clockwise) = anglesAndDirectionForCircularTransition()
        
        let arcPath = UIBezierPath()
        arcPath.addArcWithCenter(center, radius: CGFloat(radius), startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: clockwise)
        arcPath.closePath()
        maskLayer.path = arcPath.CGPath
        
        if operation == .Present {
            maskLayer.strokeEnd = 0.0
        }
        else {
            maskLayer.strokeEnd = 1.0
        }
        
        layer.mask = maskLayer
        
        CATransaction.setCompletionBlock {
            layer.mask.removeAllAnimations()
            layer.mask = nil
            
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAAnimationLinear)
        if operation == .Present {
            animation.toValue = NSNumber(float: 1.0)
        }
        else {
            animation.toValue = NSNumber(float: 0.0)
        }
        
        maskLayer.addAnimation(animation, forKey: "strokeEnd")
    }
}