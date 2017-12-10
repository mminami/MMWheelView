//
//  WheelView.swift
//  MMWheelView
//
//  Created by mminami on 2017/12/09.
//  Copyright © 2017 mminami. All rights reserved.
//

import Foundation
import UIKit

struct Point {
    var x = 0.0
    var y = 0.0
}

func degreeToRadian(_ degree: Double) -> Double {
    return Measurement(value: degree, unit: UnitAngle.degrees).converted(to: .radians).value
}

public class Basket: UIView {

}

class RotationView: UIView {
    var circleRadius: CGFloat = 100.0

    var circleColor = UIColor.white

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawCircle()
    }

    private func drawCircle() {
        let path = UIBezierPath(
            arcCenter: center,
            radius: circleRadius,
            startAngle: 0,
            endAngle: CGFloat(degreeToRadian(360)),
            clockwise: true
        )
        circleColor.setStroke()
        path.stroke()
    }
}

public protocol WheelViewDataSource: class {
    func numberOfBaskets(in wheelView: WheelView) -> Int
    func wheelView(_ view: WheelView, basketForRowAt index: Int) -> Basket
}

public class WheelView: UIView {
    weak var dataSource: WheelViewDataSource?

    var circleRadius: CGFloat = 100.0
    var circleColor = UIColor.white

    private var baskets = [Basket]()
    private var angle = 0.0
    private var touchBeginRadian = 0.0

    private(set) var animating: Bool = false {
        didSet {
            if animating {
                rotate()
            }
        }
    }

    lazy var rotationView: RotationView = {
        let view = RotationView()
        view.circleRadius = circleRadius
        view.circleColor = circleColor
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()

    public override func draw(_ rect: CGRect) {
        super.draw(rect)

        rotationView.frame = frame

        baskets.enumerated().forEach { [unowned self] (offset, value) in
            let delta = Double((360 / baskets.count) * offset)
            let radian = degreeToRadian(delta)
            let x = self.circleRadius * CGFloat(cos(radian)) + self.rotationView.center.x
            let y = self.circleRadius * CGFloat(sin(radian)) + self.rotationView.center.y
            value.center = CGPoint(x: x, y: y)
        }
    }

    func startRotating() {
        animating = true
    }

    func stopRotating() {
        animating = false
    }

    private func calcAngle(a: Point, b: Point) -> Double {
        var radian = atan2(b.y - a.y, b.x - a.x)
        if radian < 0 {
            radian = radian + 2 * Double.pi
        }
        return radian * 360 / (2 * Double.pi)
    }

    @objc private func rotate(with options: UIViewKeyframeAnimationOptions = [.allowUserInteraction]) {
        UIView.animateKeyframes(withDuration: 0.08,
                                delay: 0,
                                options: options,
                                animations: {
                                    let radian = degreeToRadian(self.angle)
                                    self.baskets.forEach { $0.transform = CGAffineTransform(rotationAngle: -CGFloat(radian)) }
                                    self.rotationView.transform = CGAffineTransform(rotationAngle: CGFloat(radian))
        }) { (completion) in
            if self.animating {
                self.angle = self.angle + 1
                self.rotate()
            }
        }
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        addSubview(rotationView)

        if let numberOfBaskets = dataSource?.numberOfBaskets(in: self) {
            for i in 0..<numberOfBaskets {
                if let basket = dataSource?.wheelView(self, basketForRowAt: i) {
                    rotationView.addSubview(basket)
                    baskets.append(basket)
                }
            }
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)

        stopRotating()

        touchBeginRadian = self.calcAngle(
            a: Point(x: Double(rotationView.center.x), y: Double(rotationView.center.y)),
            b: Point(x: Double(location.x), y: Double(location.y))
        )
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)

        let delta = self.calcAngle(
            a: Point(x: Double(rotationView.center.x), y: Double(rotationView.center.y)),
            b: Point(x: Double(location.x), y: Double(location.y))
        )

        let angle = delta - touchBeginRadian + self.angle

        let radian = degreeToRadian(angle)

        self.baskets.forEach { $0.transform = CGAffineTransform(rotationAngle: -CGFloat(radian)) }
        self.rotationView.transform = CGAffineTransform(rotationAngle: CGFloat(radian))
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)

        let delta = self.calcAngle(
            a: Point(x: Double(rotationView.center.x), y: Double(rotationView.center.y)),
            b: Point(x: Double(location.x), y: Double(location.y))
        )

        self.angle = delta - touchBeginRadian + self.angle

        let radian = degreeToRadian(self.angle)

        self.baskets.forEach { $0.transform = CGAffineTransform(rotationAngle: -CGFloat(radian)) }
        self.rotationView.transform = CGAffineTransform(rotationAngle: CGFloat(radian))

        startRotating()
    }
}
