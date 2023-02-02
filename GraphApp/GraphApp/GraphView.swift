//
//  GraphView.swift
//  GraphApp
//
//  Created by Данила on 21.10.2022.
//

import UIKit

class GraphView: UIView {
    
    /// ViewController that contains the graph.
    weak var parentVC: ViewController?
    weak var grView: GraphView?
    
    var graph = Graph()
    
    var isDeleted: Int = 0
    var lastCount = 1
    var firstAdding = true
    var visited = [Node]()

    // массив выбранных вершин
    var selectedNodes = [Node]()
    
    // возвращает ребро между выбранными вершинами
    var selectedEdge: Edge? {
        return selectedNodes.count == 2 ? graph.edge(from: selectedNodes.first!, to: selectedNodes.last!, isDirected: false) : nil
    }
    
    // режим графа
    var mode: GraphMode = .nodes
    
    // ориентированность графа
    var isDirected: Bool = true
    {
        didSet {
            graph.edges.forEach({ (edge) in edge.setNeedsDisplay() })
        }
    }
    
    // взвешенность графа
    var isWeighted: Bool = true
    {
        didSet {
            if !isWeighted {
                graph.edges.forEach({ (edge) in edge.deleteLabels()})
            }
            parentVC?.updateWeightButtons()
        }
    }
    
    // ----------------- DFS ---------------
    
    var isDFS: Bool = false
    {
        didSet {
            if isDFS {
                dfs(selectedNodes[0])
            }
            else {
                for n in graph.nodes {
                    n.fillColor = UIColor.black
                    n.strokeColor = UIColor.black
                    n.visitedDFS = false
                }
            }
        }
    }
    
    // ----------------- BFS ---------------
    var isBFS: Bool = false
    {
        didSet {
            if isBFS {
                bfs(selectedNodes[0])
            }
            else {
                for n in graph.nodes {
                    n.fillColor = UIColor.black
                    n.strokeColor = UIColor.black
                    n.visitedBFS = false
                }
            }
        }
    }
    
    // -------------------------------------
    
    // удаление графа
    func deleteGraph() {
        for i in graph.nodes {
            delete(i)
        }
        deselectNodes()
        graph = Graph()
    }
    
    // добавление ребра между вершинами A и B
    func addEdgeFromAtoB(from a: Node, to b: Node) {
        if a != b && !b.isAdjacent(to: a) {
            let edge = Edge(from: a, to: b)
            addEdge(edge)
        }
        
        deselectNodes()
    }
    
    // добавление ребра в сет ребер + вывод во вьюшку графа
    func addEdge(_ edge: Edge) {
        graph.addEdge(edge)
        addSubview(edge)
        sendSubviewToBack(edge)
    }
    
    // добавление вершины при нажатии в массив вершин + вывод во вьюшку графа
    private func addNode(with touches: Set<UITouch>) {
        for touch in touches {
            
            let location = touch.location(in: self)
            let node = Node(color: UIColor.black, at: location)
            
            if firstAdding {
                node.label.text = String(graph.nodes.count + 1)
            }
            else {
                node.label.text = String(lastCount + 1)
                lastCount += 1
            }
                                    
            graph.addNode(node)
            addSubview(node)
        }
    }
    
    // удаление вершин + удаление их из вьюшки
    func delete(_ node: Node) {
        // удаление ребер, которые соответствовали данной вершине
        node.edges.forEach({ (edge) in edge.removeFromSuperview() })
        
        node.removeFromSuperview()
        graph.remove(node)
    }
    
    // удаление выбранных вершин
    func deleteSelectedNodes() {
        if firstAdding {
            lastCount = graph.nodes.count
            firstAdding = false
        }
        guard !selectedNodes.isEmpty else { return }
        for node in selectedNodes {
            delete(node)
        }
        
        selectedNodes.removeAll()
        
    }
    
    // функция добавления вершин в массив выбранных вершин при их выделении
    func select(_ node: Node) {
        // если в массиве выбранных вершин уже присутствует выбранная вершина
        if (selectedNodes.contains(node)) {
            // убираем из выбранных вершин
            node.isSelected = false
            selectedNodes.remove(at: selectedNodes.firstIndex(of: node)!)
            
        } else {
            // добавляем в выбранные вершины
            node.isSelected = true
            selectedNodes.append(node)
        }
    }
    
    // убираем из массива выбранных вершин все вершины при выходе Selected
    func deselectNodes() {
        selectedNodes.forEach({ (node) in node.isSelected = false })
        selectedNodes.removeAll()
    }
    
    
    
    // удаление выбранных ребер
    func deleteSelectedEdge() {
        if let edge = selectedEdge {
            edge.removeFromSuperview()
            graph.remove(edge)
        }
    }
    
    // удаление всех вершин
    func deleteAllEdges() {
        graph.edges.forEach({ (edge) in edge.removeFromSuperview() })
        graph.removeAllEdges()
    }
    
    // изменение веса при нажатии на кнопки "+" или "-"
    func changeSelectedEdgeWeight(by newWeight: Int) {
        if let edge = selectedEdge {
            edge.weight += newWeight
            edge.updateLabel()
        }
    }
    
    // функция окончания нажатия
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // добавление вершины при окончании нажатия
        addNode(with: touches)
    }

}


// расширение алгоритмов для графа
extension GraphView {
    
    // DFS
    func visit(_ vertex: Node) {
        vertex.strokeColor = UIColor.blue
        vertex.fillColor = UIColor.blue
    }
    
    func dfs(_ root: Node?) {
        guard let root = root else {
            return
        }
        visit(root)
        root.visitedDFS = true
        for edge in root.adjacentNodes() {
            if !edge.visitedDFS {
                dfs(edge)
            }
        }
        
    }
    
    // BFS
    func visitBFS(_ vertex: Node) {
        vertex.strokeColor = UIColor.green
        vertex.fillColor = UIColor.green
    }

    func bfs(_ root: Node?) {
        guard let root = root else { return }
        var queue = [Node]()
        
        queue.append(root)
        root.visitedBFS = true
        
        while !queue.isEmpty {
            let vertex = queue.removeFirst()
            visitBFS(vertex)

            for edge in vertex.adjacentNodes() {
                if !edge.visitedBFS {
                    queue.append(edge)
                    edge.visitedBFS = true
                }
            }
        }
    }
    
}

// режим графа
public enum GraphMode {
    case select // выбор вершины
    case viewOnly // только просмотр
    case nodes // добавление вершины
    case edges // добавление ребра
}



