//
//  TableViewConfiguration.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 02.07.2023.
//

import UIKit

extension HomeViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < tasks.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
            cell.set(with: tasks[indexPath.row])
            cell.statusButton.tag = indexPath.row
            cell.delegate = self
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTaskTableViewCell", for: indexPath) as? CreateTaskTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < tasks.count {
            let currentItem = tasks[indexPath.row]
            let vc = DetailViewController(currentItem: currentItem)
            let navController = UINavigationController(rootViewController: vc)
            navController.transitioningDelegate = self
            navController.modalPresentationStyle = .custom
            self.present(navController, animated: true)
            vc.completionHandler = { [self] item in
                if let item = item {
                    tasks[indexPath.row] = item
                } else {
                    tasks.remove(at: indexPath.row)
                }
                saveDataAndReloadCell()
            }
        } else {
            createNewItem()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        
        let markAsDoneAction = UIContextualAction(style: .normal, title: "Done") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            tasks[indexPath.row].isDone ? markTaskAsUndone(at: indexPath.row) : markTaskAsDone(at: indexPath.row)
            saveDataAndReloadCell()
            completionHandler(true)
        }
        
        let image = UIImage(systemName: "checkmark.circle.fill")
        markAsDoneAction.image = image?.withTintColor(.white, renderingMode: .alwaysOriginal)
        markAsDoneAction.backgroundColor = .greenDisplay
        let configuration = UISwipeActionsConfiguration(actions: [markAsDoneAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Done") { [weak self] _, _, _ in
            guard let self = self else { return }
            deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveDataAndReloadCell()
        }
        
        let image = UIImage(systemName: "trash.fill")
        deleteAction.image = image
        deleteAction.backgroundColor = .redDisplay
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
}
