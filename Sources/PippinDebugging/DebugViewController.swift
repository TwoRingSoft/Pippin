//
//  DebugViewController.swift
//  PippinDebugging
//
//  Created by Andrew McKnight on 7/31/17.
//  Copyright © 2019 Two Ring Software. All rights reserved.
//

import Anchorage
import Pippin
import UIKit

protocol DebugViewControllerDelegate {
    func debugViewControllerDisplayedMenu(debugViewController: DebugViewController)
    func debugViewControllerHidMenu(debugViewController: DebugViewController)
}

public class DebugViewController: UIViewController {

    private var delegate: DebugViewControllerDelegate!
    private var environment: Environment
    private var debugMenu: UIView!
    private var displayButton: UIButton!
    private var assetBundle: Bundle?

    init(delegate: DebugViewControllerDelegate, environment: Environment, assetBundle: Bundle? = nil, buttonTintColor: UIColor, buttonStartLocation: CGPoint, appControlPanel: UIView? = nil) {
        self.delegate = delegate
        self.environment = environment
        self.assetBundle = assetBundle
        super.init(nibName: nil, bundle: nil)
        setUpUI(buttonTintColor: buttonTintColor, buttonStartLocation: buttonStartLocation, appControlPanel: appControlPanel)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

@objc extension DebugViewController {

    func closePressed() {
        debugMenu.isHidden = true
        displayButton.isHidden = false
        delegate.debugViewControllerHidMenu(debugViewController: self)
    }

    func displayPressed() {
        debugMenu.isHidden = false
        displayButton.isHidden = true
        delegate.debugViewControllerDisplayedMenu(debugViewController: self)
    }

    func draggedDisplayButton(recognizer: UIPanGestureRecognizer) {
        guard let button = recognizer.view else { return }
        let translation = recognizer.translation(in: view)
        button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        recognizer.setTranslation(.zero, in: view)
    }

}

private extension DebugViewController {

    func setUpUI(buttonTintColor: UIColor, buttonStartLocation: CGPoint, appControlPanel: UIView? = nil) {
        debugMenu = UIView(frame: .zero)
        debugMenu.isHidden = true
        debugMenu.backgroundColor = .white
        view.addSubview(debugMenu)
        debugMenu.fillSuperview()
        
        let scrollView = UIScrollView(frame: .zero)
        debugMenu.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let stackWidthSizingView = UIView(frame: .zero)
        debugMenu.addSubview(stackWidthSizingView)
        stackWidthSizingView.horizontalAnchors == debugMenu.horizontalAnchors
        stackWidthSizingView.heightAnchor == 0
        stackWidthSizingView.topAnchor == debugMenu.topAnchor

        var controlPanels = [UIView]()

        let debuggingControls: [UIView?] = [
            environment.model?.debuggingControlPanel(),
            environment.activityIndicator?.debuggingControlPanel(),
            environment.alerter?.debuggingControlPanel(),
            environment.crashReporter?.debuggingControlPanel(),
            environment.locator?.debuggingControlPanel(),
            environment.logger?.debuggingControlPanel(),
            environment.touchVisualizer?.debuggingControlPanel(),
            environment.bugReporter?.debuggingControlPanel(),
            ]
        debuggingControls.forEach {
            if let view = $0 {
                controlPanels.append(view)
            }
        }
        
        let closeButton = UIButton(frame: .zero)
        closeButton.configure(title: "Close", target: self, selector: #selector(closePressed))
        controlPanels.append(closeButton)

        if let appControlPanel = appControlPanel {
            controlPanels.insert(appControlPanel, at: 0)
        }

        let stack = UIStackView(arrangedSubviews: controlPanels)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        
        scrollView.addSubview(stack)
        stack.edgeAnchors == scrollView.edgeAnchors
        stack.widthAnchor == stackWidthSizingView.widthAnchor

        displayButton = UIButton.button(withImageSetName: "debug", emphasisSuffix: "-pressed", tintColor: buttonTintColor, target: self, selector: #selector(displayPressed), imageBundle: assetBundle)
        let size: CGFloat = 50
        displayButton.frame = CGRect(x: buttonStartLocation.x, y: buttonStartLocation.y, width: size, height: size)
        displayButton.layer.cornerRadius = size / 2
        displayButton.layer.borderWidth = 2
        displayButton.layer.borderColor = buttonTintColor.cgColor
        view.addSubview(displayButton)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(draggedDisplayButton))
        displayButton.addGestureRecognizer(panGestureRecognizer)
    }

}
