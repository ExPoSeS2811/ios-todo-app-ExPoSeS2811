//
//  ContextMenu.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 02.07.2023.
//

import UIKit

extension HomeViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < homeViewModel.items.count else { return nil }
        
        let identifier = indexPath as NSCopying
        
        var menuItem1: UIAction!
        if !homeViewModel.items[indexPath.row].isDone {
            menuItem1 = UIAction(title: "Mark As Done") { [weak self] _ in
                guard let self = self else { return }
                homeViewModel.items[indexPath.row].isDone = true
                homeViewModel.saveData()
            }
            
            menuItem1.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            menuItem1 = UIAction(title: "Mark As Undone") { [weak self] _ in
                guard let self = self else { return }
                homeViewModel.items[indexPath.row].isDone = false
                homeViewModel.saveData()
            }
            
            menuItem1.image = UIImage(systemName: "circle")
        }
        
        let deleteItem = UIAction(title: "Delete") { [weak self] _ in
            guard let self = self else { return }
            homeViewModel.deleteItem(at: indexPath.row)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.redDisplay,
        ]
        let title = NSAttributedString(string: "Delete", attributes: attributes)
        deleteItem.setValue(title, forKey: "attributedTitle")
        deleteItem.image = UIImage(systemName: "trash")?.withTintColor(.redDisplay, renderingMode: .alwaysOriginal)
        
        let menu = UIMenu(children: [menuItem1, deleteItem])
        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: { DetailViewController(currentItem: self.homeViewModel.items[indexPath.row]) }) { _ in menu }
    }
}

extension HomeViewController {
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath else {
            return
        }
        
        let vc = DetailViewController(currentItem: homeViewModel.items[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.disableInteracted()
        show(vc, sender: self)
    }
}
