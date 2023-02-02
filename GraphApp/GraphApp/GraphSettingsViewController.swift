//
//  GraphSettingsViewController.swift
//  GraphApp
//
//  Created by Данила on 25.10.2022.
//

import UIKit

class GraphSettingsViewController: UITableViewController {
    
    weak var viewControllerDelegate: ViewController!
    weak var graphView: GraphView!
    
    @IBOutlet weak var directedSwitcher: UISwitch!
    
    @IBOutlet weak var dfsSwitcher: UISwitch!
    
    // кнопка возвращения на предыдущую страницу с которой осуществлен переход через dismiss
    @IBAction func BackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // кнопка ориентированности графа
    @IBAction func directedSwitcher(_ sender: UISwitch) {
        graphView.isDirected = sender.isOn
    }
    
    
    
    // кнопка взвешенности графа
    @IBAction func weightedSwitcher(_ sender: UISwitch) {
        graphView.isWeighted = sender.isOn
    }
    
    @IBAction func dfsAlgorithm(_ sender: UISwitch) {
        graphView.isDFS = sender.isOn
    }
    
    @IBAction func bfsAlgorithm(_ sender: UISwitch) {
        graphView.isBFS = sender.isOn
    }
    
    // создание UITableView, где размещены кнопки ориентированности и взвешенности графа
    func tableView( tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
}

