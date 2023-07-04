//
//  ContextMenu.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 02.07.2023.
//

import UIKit

extension HomeViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < tasks.count else { return nil }
        
        let identifier = indexPath as NSCopying
        
        var menuItem1: UIAction!
        if !tasks[indexPath.row].isDone {
            menuItem1 = UIAction(title: "Mark As Done") { [weak self] _ in
                guard let self = self else { return }
                self.markTaskAsDone(at: indexPath.row)
                self.saveDataAndReloadCell()
            }
            
            menuItem1.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            menuItem1 = UIAction(title: "Mark As Undone") { [weak self] _ in
                guard let self = self else { return }
                self.markTaskAsUndone(at: indexPath.row)
                self.saveDataAndReloadCell()
            }
            
            menuItem1.image = UIImage(systemName: "circle")
        }
        
        let menuItem2 = UIAction(title: "Delete") { [weak self] _ in
            guard let self = self else { return }
            self.deleteTask(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.saveDataAndReloadCell()
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.redDisplay,
        ]
        let title = NSAttributedString(string: "Delete", attributes: attributes)
        menuItem2.setValue(title, forKey: "attributedTitle")
        menuItem2.image = UIImage(systemName: "trash")?.withTintColor(.redDisplay, renderingMode: .alwaysOriginal)
        
        let menu = UIMenu(children: [menuItem1, menuItem2])
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: { DetailViewController(currentItem: self.tasks[indexPath.row]) }) { _ in
            menu
        }
    }
}

extension HomeViewController {
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else {
            return
        }
        
        let currentItem = tasks[indexPath.row]
        let vc = DetailViewController(currentItem: currentItem)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.disableInteracted()
        show(vc, sender: self)
    }
}
