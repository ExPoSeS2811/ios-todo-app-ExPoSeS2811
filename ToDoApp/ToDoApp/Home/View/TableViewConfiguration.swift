//
//  TableViewConfiguration.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 02.07.2023.
//

import UIKit

extension HomeViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.items.count + 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < homeViewModel.items.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell else { return UITableViewCell() }
            cell.statusButton.tag = indexPath.row
            cell.delegate = self
            cell.set(with: homeViewModel.items[indexPath.row])
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateTaskTableViewCell", for: indexPath) as? CreateTaskTableViewCell else { return UITableViewCell() }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < homeViewModel.items.count {
            let vc = DetailViewController(currentItem: homeViewModel.items[indexPath.row])
            let navController = UINavigationController(rootViewController: vc)
            navController.transitioningDelegate = self
            navController.modalPresentationStyle = .custom
            self.present(navController, animated: true)
            vc.completionHandler = { [self] item in
                if let item = item {
                    homeViewModel.items[indexPath.row] = item
                    homeViewModel.saveData()
                    networking.makeRequest(with: .put(item.id, item), completion: { result in
                        // TODO: Realization isDirty
                        print("is dirty need to realize")
                    })
                } else {
                    networking.makeRequest(with: .delete(homeViewModel.items[indexPath.row].id), completion: { result in
                        // TODO: Realization isDirty
                        print("is dirty need to realize")
                    })
                    homeViewModel.deleteItem(at: indexPath.row)
                }
            }
        } else {
            createNewItem()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < homeViewModel.items.count else { return nil }
        
        let markAsDoneAction = UIContextualAction(style: .normal, title: "Done") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            homeViewModel.items[indexPath.row].isDone.toggle()
            networking.makeRequest(with: .put(homeViewModel.items[indexPath.row].id, homeViewModel.items[indexPath.row]), completion: { result in
                // TODO: Realization isDirty
                print("is dirty need to realize")
            })
            homeViewModel.saveData()
            completionHandler(true)
        }
        
        if homeViewModel.items[indexPath.row].isDone {
            markAsDoneAction.image = UIImage(systemName: "circle")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            markAsDoneAction.backgroundColor = .grayDisplay
            markAsDoneAction.title = "Undone"
        } else {
            markAsDoneAction.image = UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
            markAsDoneAction.backgroundColor = .greenDisplay
        }
        let configuration = UISwipeActionsConfiguration(actions: [markAsDoneAction])
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.row < homeViewModel.items.count else { return nil }
        
        let deleteAction = UIContextualAction(style: .normal, title: "Done") { [weak self] _, _, _ in
            guard let self = self else { return }
            networking.makeRequest(with: .delete(homeViewModel.items[indexPath.row].id), completion: { result in
                // TODO: Realization isDirty
                print("is dirty need to realize")
            })
            homeViewModel.deleteItem(at: indexPath.row)
        }
        
        let image = UIImage(systemName: "trash.fill")
        deleteAction.image = image
        deleteAction.backgroundColor = .redDisplay
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        
        return configuration
    }
}
