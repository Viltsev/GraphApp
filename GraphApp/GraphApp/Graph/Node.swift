//
//  Node.swift
//  GraphApp
//
//  Created by Данила on 21.10.2022.
//

import UIKit

@IBDesignable class Node: UIView {
    
    // диаметр вершины
    static let diameter: CGFloat = 48
    
    // радиус вершины
    static let radius: CGFloat = diameter / 2
    
    // ребра, связывающие вершины
    var edges = Set<Edge>()
    
    // посещенность вершины
    var visitedDFS: Bool = false
    var visitedBFS: Bool = false
    
    // ширина линии вершины
    static var lineWidth: CGFloat = diameter / 6
    
    // цвет границы вершины
    var strokeColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // цвет вершины
    var fillColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // цвет вершины
    var color: UIColor! {
        didSet {
            strokeColor = self.color
            fillColor = self.color
        }
    }
    
    // цвет выделенной вершины
    var isSelected: Bool = false {
        didSet {
            if self.isSelected { // если выбрана - меняю цвет на красный
                strokeColor = UIColor.red
                fillColor = UIColor.red
                label.textColor = UIColor.white
            } else { // иначе вершина черная
                strokeColor = initialColor
                fillColor = initialColor
                label.textColor = UIColor.white
            }
        }
    }
    
    /// Whether the node is highlighted.
    var isHighlighted: Bool = false
    
    // текущий цвет
    private let initialColor: UIColor
    
    // label вершины
    var label = UILabel()
    
    // переменная, отвечающая за то, была ли перетащена пользователем вершина
    private var isBeingDragged = false
    
    init(color: UIColor = UIColor.lightGray, at location: CGPoint) {
        initialColor = color
        
        super.init(frame: CGRect(x: location.x - Node.radius, y: location.y - Node.radius, width: Node.diameter, height: Node.diameter))
        
        // инициализация цвета вершины
        self.color = color
        strokeColor = self.color
        fillColor = self.color
        
        // инициализация label вершины
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.center
        
        // возможность взаимодействия пользователя с вершиной
        isUserInteractionEnabled = true
        
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        initialColor = UIColor.lightGray
        
        super.init(coder: aDecoder)
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
    }
    
    // все соседние вершины для данной вершины
    func adjacentNodes(directed: Bool = true) -> Set<Node> {
        var results = Set<Node>()

        for edge in edges {
            if edge.startNode! != self && !directed {
                results.insert(edge.startNode!)
            } else if edge.endNode! != self {
                results.insert(edge.endNode!)
            }
        }

        return results
    }
    
    // проверка на то, являеются ли две вершины соседними
    func isAdjacent(to node: Node, directed: Bool = true) -> Bool {
        if adjacentNodes(directed: directed).contains(node) {
            return true
        } else {
            return false
        }
    }
    
    
    
    
    
    // отрисовка вершины
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(ovalIn: rect.insetBy(dx: Node.lineWidth / 2, dy: Node.lineWidth / 2))
        path.lineWidth = Node.lineWidth
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.stroke()
        
        label.drawText(in: rect)
    }
    
    // функция начала взаимодействия с вершиной
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.bringSubviewToFront(self)
    }
    
    // функция конца взаимодействия с вершиной
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isBeingDragged else {
            isBeingDragged = false
            return
        }
        
        let graph = superview as! GraphView
        
        if graph.mode == .select || graph.mode == .edges {
            graph.select(self)

            if graph.mode == .edges && graph.selectedNodes.count == 2 {
                graph.addEdgeFromAtoB(from: graph.selectedNodes.first!, to: graph.selectedNodes.last!)
            }
        }
    }
    
    // перемещение вершины
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard (superview as! GraphView).mode != .viewOnly else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            
            if abs(location.x - previousLocation.x) + abs(location.y - previousLocation.y) < 2 {
                break
            }
            
            isBeingDragged = true
            
            frame = frame.offsetBy(dx: (location.x - previousLocation.x), dy: (location.y - previousLocation.y))
        }
        
        for edge in edges {
            edge.followConnectedNodes()
        }
    }
    
}
