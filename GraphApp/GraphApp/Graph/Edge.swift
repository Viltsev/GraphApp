//
//  Edge.swift
//  GraphApp
//
//  Created by Данила on 21.10.2022.
//

import UIKit

@IBDesignable class Edge: UIView {
    
    // толщина ребра
    private let lineWidth: CGFloat = 4
    
    // переменная, которая необходима для отрисовки ребра из точки startPoint в точку endPoint
    private var path = UIBezierPath()
    
    // начальная координата точки отрисовки
    private var startPoint: CGPoint?
    
    // конечная координата точки отрисовки
    private var endPoint: CGPoint?
    
    // label-вес для ребра
    private var label: UILabel!
    
    // начальная вершина
    var startNode: Node!
    
    // конечная вершина
    var endNode: Node!
    
    // вес вершины
    var weight = 1
    
    init() {
        super.init(frame: CGRect())
    }
    
    init(from startNode: Node, to endNode: Node) {
        self.startNode = startNode
        self.endNode = endNode
        
        super.init(frame: CGRect())
        
        // связь вершин с ребрами
        startNode.edges.insert(self)
        endNode.edges.insert(self)
        
        updateDistance()
        updateCoordinates()
        
        label = UILabel(frame: CGRect(x: bounds.midX, y: bounds.midY, width: 64, height: 64))
        
        label.textColor = UIColor.black
        
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = NSTextAlignment.left
        addSubview(label)
        
        backgroundColor = UIColor.clear
        
        clearsContextBeforeDrawing = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // обновление координат вершин
    func updateCoordinates() {
        // set location of frame around nodes
        frame.origin = CGPoint(x: min(startNode!.frame.origin.x, endNode!.frame.origin.x), y: min(startNode!.frame.origin.y, endNode!.frame.origin.y))
    }
    
    // обновление расстояния между вершинами, для того чтобы перерисовать ребро
    func updateDistance() {
        // determine size of frame
        let width = abs(startNode!.frame.origin.x - endNode!.frame.origin.x) + Node.diameter
        let height = abs(startNode!.frame.origin.y - endNode!.frame.origin.y) + Node.diameter
        let size = CGSize(width: width, height: height)
    
        frame.size = size
    }
    
    // перерисовка самого ребра после перемещения вершин
    private func updatePath() {
        path = UIBezierPath()
        
        locatePointsInFrame()
        
        let headWidth = Node.radius / 2.2
        let headLength = headWidth
        
        let length = hypot(endPoint!.x - startPoint!.x, endPoint!.y - startPoint!.y)
        let tailLength = length - Node.radius - headLength
        
        let points: [CGPoint] = [
            CGPoint(x: 0, y: 0),
            CGPoint(x: length, y: 0),
        ]
        
        let cosine = (endPoint!.x - startPoint!.x) / length
        let sine = (endPoint!.y - startPoint!.y) / length
        
        // reorient the line to match slope between nodes
        let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint!.x, ty: startPoint!.y)
        
        let linePath = CGMutablePath()
        linePath.addLines(between: points, transform: transform)
        
        // add arrow for directed graph
        if (superview as! GraphView).isDirected {
            let tipPoint = CGPoint(x: length - Node.radius, y: 0)
            
            linePath.move(to: tipPoint, transform: transform)
            linePath.addLine(to: CGPoint(x: tailLength, y: headWidth / 1.2), transform: transform)
            
            linePath.move(to: tipPoint, transform: transform)
            linePath.addLine(to: CGPoint(x: tailLength, y: -headWidth / 1.2), transform: transform)
        }
        
        linePath.closeSubpath()
        path.append(UIBezierPath(cgPath: linePath))
        
        // update location of label
        label.frame.origin = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    // обновление данных о ребре после перемещения вершины
    func followConnectedNodes() {
        updateDistance()
        updateCoordinates()
        updatePath()
        setNeedsDisplay()
    }
    
    // обновление надписи веса при его изменении
    func updateLabel(transitionDuration: Double = 0.2) {
        guard label != nil else { return }
        label.changeWeightText(to: String(weight), duration: transitionDuration)
    }
    
    // удаление надписи веса, если граф делаем невзвешенным
    func deleteLabels(transitionDuration: Double = 0.2) {
        guard label != nil else { return }
        label.changeWeightText(to: "", duration: transitionDuration)
    }
    
    // функция, которая определяет координаты середины вершины
    private func locatePointsInFrame() {
        let upperLeft = CGPoint(x: Node.radius, y: Node.radius)
        let lowerLeft = CGPoint(x: Node.radius, y: frame.size.height - Node.radius)
        let upperRight = CGPoint(x: frame.size.width - Node.radius, y: Node.radius)
        let lowerRight = CGPoint(x: frame.size.width - Node.radius, y: frame.size.height - Node.radius)
        
        if startNode!.frame.origin.y > frame.origin.y {
            if startNode!.frame.origin.x <= frame.origin.x {
                startPoint = lowerLeft
                endPoint = upperRight
            } else {
                startPoint = lowerRight
                endPoint = upperLeft
            }
        } else if startNode!.frame.origin.y <= frame.origin.y {
            if startNode!.frame.origin.x <= frame.origin.x {
                startPoint = upperLeft
                endPoint = lowerRight
            } else {
                startPoint = upperRight
                endPoint = lowerLeft
            }
        }
    }
    
    
    
    // отрисовка ребра
    override func draw(_ rect: CGRect) {
        updatePath()
        
        path.lineWidth = lineWidth
        
        path.stroke()
    }
    
}

extension UILabel {
    // изменение надписи веса при изменении веса
    func changeWeightText(to newText: String, duration: Double = 0.5) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            self.text = newText
        }, completion: nil)
    }
}
