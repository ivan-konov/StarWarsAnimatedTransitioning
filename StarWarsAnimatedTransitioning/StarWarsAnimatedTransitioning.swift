//
//  StarWarsAnimatedTransitioning.swift
//
//  Created by Ivan Konov on 12/18/14.
//
//The MIT License (MIT)
//
//Copyright (c) 2014-2022 Ivan Konov
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

final class StarWarsAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    enum TransitionType {
        case linearRight
        case linearLeft
        case linearUp
        case linearDown
        case circularClockwise
        case circularCounterclockwise
    }

    enum Operation {
        case present
        case dismiss
    }
    
    let duration: TimeInterval
    let operation: Operation
    let transitionType: TransitionType
    
    init(duration: TimeInterval = 0.6, operation: Operation = .present, transitionType: TransitionType = .linearRight) {
        self.duration = duration
        self.operation = operation
        self.transitionType = transitionType
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard transitionContext.isAnimated else {
            return
        }
        
        guard let fromController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
              let toController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                  print("Missing transitioning view controllers!")
                  return
              }
        
        let containerView = transitionContext.containerView
        
        var animatedLayer: CALayer
        if operation == .present {
            animatedLayer = toController.view.layer
            containerView.addSubview(toController.view)
        }
        else {
            animatedLayer = fromController.view.layer
        }
        
        performAnimationWithLayer(layer: animatedLayer) { [weak self] in
            if self?.operation == .dismiss {
                fromController.view.removeFromSuperview()
            }
            
            transitionContext.completeTransition(true)
        }
    }
    
    private func performAnimationWithLayer(layer: CALayer, completion: @escaping () -> Void) {
        switch transitionType {
        case .linearLeft, .linearRight, .linearUp, .linearDown:
            performLinearTransitionWithLayer(layer: layer, completion: completion)
        case .circularClockwise, .circularCounterclockwise:
            performCircularTransitionWithLayer(layer: layer, completion: completion)
        }
    }
    
    // MARK: - Linear Animations
    
    private func maskFrameAndPositionForLinearTransition(with layer: CALayer) -> (CGRect, CGPoint) {
        var initialMaskFrame: CGRect
        var finalPosition: CGPoint
        
        switch transitionType {
        case .linearRight:
            if operation == .present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.x -= initialMaskFrame.width
                
                finalPosition = layer.position
            } else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.x += layer.bounds.width
            }
        case .linearLeft:
            if operation == .present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.x += initialMaskFrame.width
                
                finalPosition = layer.position
            } else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.x -= layer.bounds.width
            }
        case .linearUp:
            if operation == .present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.y += layer.bounds.height
                
                finalPosition = layer.position
            } else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.y -= layer.bounds.height
            }
        case .linearDown:
            if operation == .present {
                initialMaskFrame = layer.bounds
                initialMaskFrame.origin.y -= layer.bounds.height
                
                finalPosition = layer.position
            } else {
                initialMaskFrame = layer.bounds
                
                finalPosition = layer.position
                finalPosition.y += layer.bounds.height
            }
        default:
            print("Something went wrong! Mask frame and position calculations should not be made for non-linear transition types.")
            
            initialMaskFrame = CGRect.zero
            finalPosition = CGPoint.zero
        }
        
        return (initialMaskFrame, finalPosition)
    }
    
    private func performLinearTransitionWithLayer(layer: CALayer, completion: @escaping () -> Void) {
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        layer.mask = maskLayer
        
        let (initalFrame, finalPosition) = maskFrameAndPositionForLinearTransition(with: layer)
        maskLayer.frame = initalFrame
        
        CATransaction.setCompletionBlock {
            layer.mask = nil
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = duration
        animation.fromValue = NSValue(cgPoint: maskLayer.position)
        animation.toValue = NSValue(cgPoint: finalPosition)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        maskLayer.add(animation, forKey: "position")
        maskLayer.position = finalPosition
    }
    
    // MARK: - Circular Animations
    
    private func anglesAndDirectionForCircularTransition() -> (CGFloat, CGFloat, Bool) {
        let startAngle: Double
        let endAngle: Double
        let isClockwise: Bool
        
        switch transitionType {
        case .circularClockwise:
            startAngle = -(Double.pi / 2)
            endAngle = operation == .present ? 3 * (Double.pi / 2) : -5 * (Double.pi / 2)
            isClockwise = operation == .present ? true : false
        case .circularCounterclockwise:
            startAngle = -(Double.pi / 2)
            endAngle = operation == .present ? -5 * (Double.pi / 2) : 3 * (Double.pi / 2)
            isClockwise = operation == .present ? false : true
        default:
            print("Something went wrong! No angle calculations should be made for non-circular transition types.")
            
            isClockwise = true
            startAngle = 0
            endAngle = 0
        }
        
        return (CGFloat(startAngle), CGFloat(endAngle), isClockwise)
    }
    
    private func performCircularTransitionWithLayer(layer: CALayer, completion: @escaping () -> Void) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = layer.bounds
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        
        let center = CGPoint(x: maskLayer.bounds.width / 2, y: maskLayer.bounds.height / 2)
        let radius = CGFloat(sqrt((center.x * center.x) + (center.y * center.y)) / 2)
        
        maskLayer.lineWidth = radius * 2
        
        let (startAngle, endAngle, isClockwise) = anglesAndDirectionForCircularTransition()
        let arcPath = UIBezierPath()
        arcPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: isClockwise)
        arcPath.close()
        maskLayer.path = arcPath.cgPath
        
        if operation == .present {
            maskLayer.strokeEnd = 0.0
        } else {
            maskLayer.strokeEnd = 1.0
        }
        
        layer.mask = maskLayer
        CATransaction.setCompletionBlock {
            layer.mask?.removeAllAnimations()
            layer.mask = nil
            
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        if operation == .present {
            animation.toValue = NSNumber(value: 1.0)
        } else {
            animation.toValue = NSNumber(value: 0.0)
        }
        
        maskLayer.add(animation, forKey: "strokeEnd")
    }
}
