//
//  SelectEventViewController.swift
//  SwiftAudioKitTest
//
//  Created by Hans Tutschku on 4/24/16.
//  Copyright © 2016 Hans Tutschku. All rights reserved.
//

import UIKit

// TODO: In the end, use UICollectionView. All of this calculation is done internally, 
// and it will be available for AutoLayout
class SelectEventViewController: UIViewController {
    
    // MARK: - Layout logic
    
    private let amountColumns = 15
    
    // MARK: - Appearance
    
    private let buttonWidth: CGFloat = 65
    
    private var buttonSize: CGSize {
        return CGSize(width: buttonWidth, height: buttonWidth)
    }
    
    private var events = EventCollection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        generateButtons(amount: events.count)
    }
    
    private func generateButtons(amount: Int) {
        (1 ... amount).forEach(createButton)
    }
    
    private func createButton(index: Int) {
        let button = UIButton(frame: frame(forButtonWith: index))
        button.addTarget(self, action: .buttonAction, for: .touchUpInside)
        button.setTitle(String(index), for: UIControlState())
        button.titleLabel!.font =  UIFont(name: "Helvetica-Bold", size: 30)
        button.tag = index
        button.backgroundColor = Color.dark
        self.view.addSubview(button)
    }
    
    @objc fileprivate func buttonAction(_ sender: UIButton!) {
        do {
            // FIXME: Events are 1-indexed, while `EventCollection` is 0-indexed.
            try events.go(to: sender.tag - 1)
            _ = navigationController?.popViewController(animated: true)
        } catch {
            // TODO: Manage failure to go to desired event
        }
    }
    
    private func frame(forButtonWith index: Int) -> CGRect {
        return CGRect(origin: origin(for: index), size: buttonSize)
    }
    
    private func origin(for index: Int) -> CGPoint {
        return origin(for: row(for: index), and: column(for: index))
    }
    
    private func origin(for row: Int, and column: Int) -> CGPoint {
        return CGPoint(x: x(for: column), y: y(for: row))
    }
    
    /**
     - returns: x value for a given `column`.
     */
    private func x(for column: Int) -> CGFloat {
        return CGFloat(column) * (buttonWidth + 2) + 12
    }
    
    /**
     - returns: y value for a given `row`.
     */
    private func y(for row: Int) -> CGFloat {
        return CGFloat(row) * (buttonWidth + 2) + 120
    }
    
    /**
     - returns: column for a given `index`.
     */
    private func column(for index: Int) -> Int {
        return (index - 1) % amountColumns
    }
    
    /**
     - returns: row for a given `index`.
     */
    private func row(for index: Int) -> Int {
        return (index - 1) / amountColumns
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

private extension Selector {
    static let buttonAction = #selector(SelectEventViewController.buttonAction)
}
