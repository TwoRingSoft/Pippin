//
//  ViewController.swift
//  PippinTestHarness
//
//  Created by Andrew McKnight on 4/3/17.
//
//

import UIKit

class ViewController: UIViewController {
    private let label = UILabel(frame: .zero)
    private let button = UIButton(type: .custom)
    private var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let stack = UIStackView(arrangedSubviews: [label, button])
        stack.axis = .vertical

        view.addSubview(stack)

        [stack, label, button].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])

        button.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
        button.setTitle("Increment", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        updateLabel()
    }

    @objc func pressed(_ sender: UIButton) {
        count += 1
        updateLabel()
    }

    func updateLabel() {
        label.text = "\(count)"
    }
}

