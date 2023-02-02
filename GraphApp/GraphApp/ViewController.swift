//
//  ViewController.swift
//  GraphApp
//
//  Created by Данила on 21.10.2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nodeButton: UIBarButtonItem!
    @IBOutlet weak var edgeButton: UIBarButtonItem!
    
    @IBOutlet weak var plusWeightButton: UIBarButtonItem!
    @IBOutlet weak var minusWeightButton: UIBarButtonItem!
    
    
    private var settingsVC: GraphSettingsViewController!
    private var settingsNVC: UINavigationController!
    var parentVC: ViewController!
    
    override func viewDidLoad() {
        graphView.parentVC = self
        graphSettingsController()
        updateWeightButtons()
    }

    //
    func graphSettingsController() {
        let myVC = UIStoryboard(name: "Main", bundle: nil) // текущая страничка
        // переход на Graph Settings с помощью instantiateViewController по идентификатору
        settingsNVC = myVC.instantiateViewController(withIdentifier: "actionsNavController") as? UINavigationController
        // режим отображения страницы на которую осуществлен переход
        settingsNVC.modalPresentationStyle = .fullScreen
        
        settingsVC = settingsNVC.topViewController as? GraphSettingsViewController
        settingsVC.graphView = graphView
        settingsVC.viewControllerDelegate = parentVC
        
    }
    
    
    @IBOutlet weak var graphView: GraphView!
    
    // режим добавления вершин
    @IBAction func nodeButtonAction(_ sender: UIBarButtonItem) {
        edgeButton.isEnabled = true
        nodeButton.isEnabled = false
        graphView.mode = .nodes
    }
    
    // режим добавления ребер
    @IBAction func edgeButtonAction(_ sender: UIBarButtonItem) {
        edgeButton.isEnabled = false
        nodeButton.isEnabled = true
        graphView.mode = .edges
    }
    
    // выбор режима выбора вершин
    @IBAction func selectButtonTapped(_ sender: UIBarButtonItem) {
        if graphView.mode != .select && graphView.mode != .viewOnly {
            enterSelectMode(sender)
        } else {
            exitSelectMode(sender)
        }
    }
    
    // кнопка перехода на страницу Graph Settings
    @IBAction func openGraphSettings(_ sender: UIBarButtonItem) {
        settingsNVC.popoverPresentationController?.barButtonItem = sender
        present(settingsNVC, animated: true)
    }
    
    // режим Selected
    func enterSelectMode(_ sender: UIBarButtonItem) {
        
        graphView.mode = .select
        
        sender.title = "Done"
        sender.style = .done
        
        nodeButton.isEnabled = false
        edgeButton.isEnabled = false
    }
    
    // выход из режима Selected
    func exitSelectMode(_ sender: UIBarButtonItem) {
        graphView.deselectNodes()
        
        graphView.mode = .nodes
        
        sender.title = "Select"
        sender.style = .plain
        
        nodeButton.isEnabled = true
        edgeButton.isEnabled = true
    }
    
    // кнопка удаления выбранных вершин
    @IBAction func deleteSelectedNodes(_ sender: UIBarButtonItem) {
        graphView.deleteSelectedNodes()
    }
    
    // кнопка удаления ребра между выбранными вершинами
    @IBAction func deleteSelectedEdge(_ sender: Any) {
        graphView.deleteSelectedEdge()
    }
    
    // кпопка прибавление веса
    @IBAction func updateWeight(_ sender: UIBarButtonItem) {
        graphView.changeSelectedEdgeWeight(by: 1)
    }
    
    // кнопка убавления веса
    @IBAction func updateMinusWeight(_ sender: Any) {
        graphView.changeSelectedEdgeWeight(by: -1)
    }
    
    func updateWeightButtons() {
        // если граф взвешенный - разрешено управление весом
        if graphView.isWeighted {
            plusWeightButton.isEnabled = true
            minusWeightButton.isEnabled = true
        }
        else { // иначе - запрещено
            plusWeightButton.isEnabled = false
            minusWeightButton.isEnabled = false
        }
    }
    
    @IBAction func clearGraph(_ sender: Any) {
        graphView.deleteGraph()
    }
    
}

