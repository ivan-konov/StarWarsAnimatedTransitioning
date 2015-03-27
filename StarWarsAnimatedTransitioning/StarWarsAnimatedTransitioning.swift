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

enum StarWarsTransitionType {
    case LinearRight
    case LinearLeft
    case LinearUp
    case LinearDown
    case CircularClockwise
    case CircularCounterclockwise
}

enum StarWarsOperation {
    case Present
    case Dismiss
}

class StarWarsAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var duration: NSTimeInterval = 0.65
    
    var operation: StarWarsOperation = .Present
    var type: StarWarsTransitionType = .LinearRight
    
    // MARK: Implementation
    
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
        
        setUpAnimationWithLayer(animatedLayer!) {
            if self.operation == .Dismiss {
                fromController!.view.removeFromSuperview()
            }
            
            transitionContext.completeTransition(true)
        }
    }
    
    private func setUpAnimationWithLayer(layer: CALayer, completion: () -> Void) {
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.whiteColor().CGColor // the actual color is isrrelevant; all we need is the alpha channel
        layer.mask = maskLayer
        
        let (initalFrame, finalPosition) = maskFrameAndPositionForLayer(layer)
        
        maskLayer.frame = initalFrame
        
        performTransitionWithLayer(layer, finalPosition: finalPosition, completion: completion)
    }
    
    private func maskFrameAndPositionForLayer(layer: CALayer) -> (CGRect, CGPoint){
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
            // TODO: add Circular types
            initialMaskFrame = CGRectZero;
            finalPosition = CGPointZero;
            
            break;
        }
        
        return (initialMaskFrame, finalPosition)
    }
    
    private func performTransitionWithLayer(layer: CALayer, finalPosition: CGPoint, completion: () -> Void) {
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
}