//
//  Graph.swift
//  GraphApp
//
//  Created by Данила on 21.10.2022.
//

import Foundation

class Graph {
    
    var nodes: [Node]
    var edges: Set<Edge>
    var nodeMatrix: [Node: Set<Node>]
    
    init() {
        self.nodes = [Node]()
        self.edges = Set<Edge>()
        self.nodeMatrix = [Node: Set<Node>]()
    }
    
    init(_ graph: Graph) {
        self.nodes = graph.nodes
        self.edges = graph.edges
        self.nodeMatrix = graph.nodeMatrix
    }
    
    // функция добавления вершины
    func addNode(_ node: Node) {
        nodes.append(node)
        nodeMatrix[node] = Set<Node>()
    }
    
    // функция добавления ребра
    func addEdge(_ edge: Edge) {
        nodeMatrix[edge.startNode]?.insert(edge.endNode)
        nodeMatrix[edge.endNode]?.insert(edge.startNode)
        edges.insert(edge)
    }
    
    // удаление вершины
    func remove(_ node: Node) {
        
        // удаление ребра которое связано с данной вершинной
        for edge in node.edges {
            removeEdgeFromNodes(edge)
        }
        
        // удаление вершины из массива вершин и матрицы вершин
        nodes.remove(at: nodes.firstIndex(of: node)!)
        nodeMatrix.removeValue(forKey: node)
        
        for (_, var adjacents) in nodeMatrix {
            adjacents.remove(node)
        }
    }
    
    // функция удаления ребра (для удаления информации о ребре между вершинами)
    private func removeEdgeFromNodes(_ edge: Edge) {
        let index1 = edge.startNode?.edges.firstIndex(of: edge)
        let index2 = edge.endNode?.edges.firstIndex(of: edge)
        
        if index1 != nil {
            edge.startNode?.edges.remove(at: index1!)
        }
        
        if index2 != nil  {
            edge.endNode?.edges.remove(at: index2!)
        }
    }
    
    // основная функция удаления ребра
    func remove(_ edge: Edge) {
        removeEdgeFromNodes(edge)
        edges.remove(edge)
        nodeMatrix[edge.startNode]?.remove(edge.endNode)
        nodeMatrix[edge.endNode]?.remove(edge.startNode)
    }
    
    // удаление всех ребер
    func removeAllEdges() {
        for node in nodes {
            node.edges.removeAll()
            nodeMatrix[node]?.removeAll()
        }
        
        edges.removeAll()
    }
    
    func edge(from a: Node, to b: Node, isDirected: Bool) -> Edge? {
        return isDirected ? edges.first(where: { $0.startNode == a && $0.endNode == b })
            : a.edges.first(where: { $0.startNode == b || $0.endNode == b })
    }
    
}
