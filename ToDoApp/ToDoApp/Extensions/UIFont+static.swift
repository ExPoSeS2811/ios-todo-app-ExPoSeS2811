//
//  UIFont+static.swift
//  ToDoApp
//
//  Created by Gleb Rasskazov on 22.06.2023.
//

import UIKit

extension UIFont {
    static var largeTitle: UIFont? { UIFont(name: "SFProDisplay-Bold", size: 38) }
    static var title: UIFont? { UIFont(name: "SFProDisplay-Semibold", size: 20) }
    static var headline: UIFont? { UIFont(name: "SFProText-Semibold", size: 17) }
    static var body: UIFont? { UIFont(name: "SFProText-Regular", size: 17) }
    static var subhead: UIFont? { UIFont(name: "SFProText-Regular", size: 15) }
    static var footnote: UIFont? { UIFont(name: "SFProText-Semibold", size: 13) }
}
