//
//  ViewController.swift
//  Plum-o-Meter
//
//  Created by Simon Gladman on 24/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    
    let label = UILabel()
    
    var circles = [UITouch: CircleWithLabel]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.isMultipleTouchEnabled = true
        
        label.text = "lay your plums on me."
        
        label.textAlignment = NSTextAlignment.center
        
        view.addSubview(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        label.isHidden = true
        
        for touch in touches
        {
            let circle = CircleWithLabel()
            
            circle.drawAtPoint(touch.location(in: view),
                force: touch.force / touch.maximumPossibleForce)
            
            circles[touch] = circle
            view.layer.addSublayer(circle)
        }
        
        highlightHeaviest()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches where circles[touch] != nil
        {
            let circle = circles[touch]!
            
            circle.drawAtPoint(touch.location(in: view),
                force: touch.force / touch.maximumPossibleForce)
        }
        
        highlightHeaviest()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch in touches where circles[touch] != nil
        {
            let circle = circles[touch]!
            
            circles.removeValue(forKey: touch)
            circle.removeFromSuperlayer()
        }
        
        highlightHeaviest()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        for touch in touches where circles[touch] != nil
        {
            let circle = circles[touch]!
            
            circle.removeFromSuperlayer()
        }
    }
    
    func highlightHeaviest()
    {
        func getMaxTouch() -> UITouch?
        {
            return circles.sorted(by: {
                (a: (UITouch, CircleWithLabel), b: (UITouch, CircleWithLabel)) -> Bool in
                
                return a.0.force > b.0.force
            }).first?.0
        }
        
        circles.forEach
        {
            $0.1.isMax = $0.0 == getMaxTouch()
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.landscape
    }
    
    override func viewDidLayoutSubviews()
    {
        label.frame = view.bounds
    }
}

// -------------

class CircleWithLabel: CAShapeLayer
{
    let text = CATextLayer()
    
    override init()
    {
        super.init()
        
        text.foregroundColor = UIColor.blue.cgColor
        text.alignmentMode = kCAAlignmentCenter
        addSublayer(text)
        
        strokeColor = UIColor.blue.cgColor
        lineWidth = 5
        fillColor = nil
    }
    
    override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isMax: Bool = false
    {
        didSet
        {
            fillColor = isMax ? UIColor.yellow.cgColor : nil
        }
    }
    
    func drawAtPoint(_ location: CGPoint, force: CGFloat)
    {
        let radius = 120 + (force * 120)
        
        path = UIBezierPath(
            ovalIn: CGRect(
                origin: location.offset(dx: radius, dy: radius),
                size: CGSize(width: radius * 2, height: radius * 2))).cgPath
        
        text.string = String(format: "%.1f%%", force * 100)
        
        text.frame = CGRect(origin: location.offset(dx: 75, dy: -radius), size: CGSize(width: 150, height: 40))
    }
}

// -------------

extension CGPoint
{
    func offset(dx: CGFloat, dy: CGFloat) -> CGPoint
    {
        return CGPoint(x: self.x - dx, y: self.y - dy)
    }
}
