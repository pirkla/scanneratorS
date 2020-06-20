//
//  LogoView.swift
//  testInterface
//
//  Created by Andrew Pirkl on 12/21/19.
//  Copyright © 2019 Pirklator. All rights reserved.
//

import SwiftUI

struct LogoView: View {
    
    var animate: Binding<Bool>
    
    static let rotationCount = 13
    var symbols: some View {
        ForEach(0..<LogoView.rotationCount) { i in
                Parallelogramb(
                    spinTime: !self.animate.wrappedValue ? 0:1,
                    animationTime: !self.animate.wrappedValue ? 0:1
                )
//                    .opacity(0.5)
                    .rotationEffect(.degrees(Double(i) / Double(LogoView.rotationCount)) * 360.0,anchor: .bottomLeading)
            .frame(width:100)
        }
        .animation(animate.wrappedValue ? Animation.linear(duration: 5.0).repeatForever(autoreverses: false) : Animation.linear(duration: 5.0))
    }
    var body: some View {
        GeometryReader { geometry in
            self.symbols
                .scaleEffect(1.0 / 4.0, anchor: .top)
                .position(x: geometry.size.width / 1.925, y: (3.0 / 4.0) * geometry.size.height)
        }
    }
}

//struct LogoView_Previews: PreviewProvider {
//    static var previews: some View {
//        LogoView(false).drawingGroup()
//    }
//}

struct ParallelogramView_Previews: PreviewProvider {
    
    static var previews: some View {
        Parallelogramb(spinTime: 0, animationTime: 0)

    }
}

struct Parallelogramb: Shape{
    var spinTime: CGFloat
    var animationTime: CGFloat
    var peakTime = 2.3
    
    var animatableData: AnimatablePair<CGFloat,CGFloat>
    {
        get{ AnimatablePair(spinTime,animationTime) }
        set {
            self.spinTime = newValue.first
            self.animationTime = newValue.second
        }
    }
    
    var triangleOffset: CGFloat{
        get {
            let x = pow((Double(animationTime)*4)-peakTime,5)
            let y = CGFloat(Double.sech(x:x)*0.75)
            let bounce = Double.sechDeriv(x:x)
            return y + CGFloat(bounce * 0.8)
        }
    }
    var testAngleB:CGFloat {
        get{
            let y = (-abs(Double(animationTime)*4-peakTime)+1)*45
            return CGFloat(Double.maximum(y,0))
        }
    }
    var testYOffset: CGFloat{
        get{
            let y = (-abs(Double(animationTime)*4-peakTime)+1) * 0.16
            return CGFloat(Double.maximum(y,0))
        }
    }
    var testAngleA:CGFloat {
        get{
            let x = Double(spinTime)
            let y = 1 / (1+pow(M_E,-25 * (x-0.5)))
            return CGFloat(y * 360)
        }
    }
    
    
    func path(in rect: CGRect) -> Path {
        let size =  rect.size.height
        
        //parallelogram points
        let points: [CGPoint] = [CGPoint(x: 0,y: 1),CGPoint(x: 0.225,y: 0.55),CGPoint(x: 0.25,y: 0),CGPoint(x: 0,y: 0.5)]
        
        let pointsb: [CGPoint] = [CGPoint(x: -0.225,y: 0),CGPoint(x: -0.005,y: 0.475),CGPoint(x: 0.225,y: 0)]
        

        var path = Path()
                
        for (index,point) in points.enumerated() {
            // transform y vector
            var myPoint = CGPoint.Transform(target: point, byVector: CGPoint(x: 0,y: testYOffset))
            // rotate around .125, .5 using angleB
            myPoint = CGPoint.Rotate(target: myPoint, aroundOrigin: CGPoint(x:0.125,y:0.5),byDegrees: testAngleB)
            // rotate around leading bottom using angleA
            myPoint = CGPoint.Rotate(target: myPoint,aroundOrigin: CGPoint(x:0,y:1),byDegrees: testAngleA)


            // scale points to the size of the rect
            myPoint = CGPoint.Scale(target: myPoint, byAmount: size)
            
            // move to the first point
            if index == 0 {
                path.move(to: myPoint)
            }
            // draw lines to each point
            else {
                path.addLine(to: myPoint)
            }
        }
        for (index,point) in pointsb.enumerated() {

            // transform y vector
            var myPoint = CGPoint.Transform(target: point, byVector: CGPoint(x: 0,y:triangleOffset))
            
            // scale points to the size of the rect
            myPoint = CGPoint.Scale(target: myPoint, byAmount: size)
            // move to the first point
            if index == 0 {
                path.move(to: myPoint)
            }
            // draw lines to each point
            else {
                path.addLine(to: myPoint)
            }
        }
        
        
        path.closeSubpath()
        return path
    }
    
}


public extension CGPoint{
    static func Rotate(target: CGPoint, aroundOrigin origin: CGPoint = CGPoint(x: 0,y: 0), byDegrees: CGFloat) -> CGPoint {
        let dx = target.x - origin.x
        let dy = target.y - origin.y
        let radius = sqrt(dx * dx + dy * dy)
        let azimuth = atan2(dy, dx) // in radians
        let newAzimuth = azimuth + byDegrees * CGFloat(.pi / 180.0) // convert it to radians
        let x = origin.x + radius * cos(newAzimuth)
        let y = origin.y + radius * sin(newAzimuth)
        return CGPoint(x: x, y: y)
    }
    static func Scale(target: CGPoint, byAmount: CGFloat) -> CGPoint
    {
        return CGPoint(x: target.x * byAmount, y: target.y * byAmount)
    }
    static func Transform(target: CGPoint, byVector: CGPoint) -> CGPoint{
        return CGPoint(x: target.x - byVector.x, y: target.y - byVector.y)
    }
}

public extension Double{
    static func sech(x: Double) -> Double{
        return 2 / (pow(M_E,x)+pow(M_E,-x))
    }
    
    static func sechDeriv(x: Double)->Double{
        return -( ( 2 * pow(M_E,x) - pow(M_E,-x)) / (pow(pow(M_E,x)+pow(M_E,-x),2)))
    }
}
