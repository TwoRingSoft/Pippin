#if canImport(UIKit)
import UIKit
import Pippin
import SwiftArmcknightUIKit

/// Presents an `InfoViewController` in a floating `UIWindow` using the
/// `TransparentModalPresentingViewController` slide-in animation.  Child views
/// (Acknowledgements, Changelog) work correctly because the window's root view
/// controller serves as `logicalParent`, keeping all presentation inside one
/// window rather than nesting inside a SwiftUI sheet.
@MainActor
public final class InfoPresenter: NSObject, @preconcurrency InfoViewControllerDelegate {
    private var window: UIWindow?
    private var modalPresenter: TransparentModalPresentingViewController?
    private var containerView: UIView?
    private var userIDToCopy: String?

    private let environment: Pippin.Environment
    private let acknowledgements: Acknowledgements
    private let contactEmails: [String]
    private let links: [LinkIcon]
    private let companyLink: LinkIcon
    private let getUserID: (() -> String?)?

    public init(
        environment: Pippin.Environment,
        acknowledgements: Acknowledgements,
        contactEmails: [String],
        links: [LinkIcon] = [],
        companyLink: LinkIcon,
        getUserID: (() -> String?)? = nil
    ) {
        self.environment = environment
        self.acknowledgements = acknowledgements
        self.contactEmails = contactEmails
        self.links = links
        self.companyLink = companyLink
        self.getUserID = getUserID
    }

    public func show() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.alert.rawValue - 1)
        window.backgroundColor = .clear
        self.window = window

        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC

        let infoVC = InfoViewController(
            acknowledgements: acknowledgements,
            textColor: environment.colors.foreground,
            contactEmails: contactEmails,
            environment: environment,
            sharedAssetBundle: Bundle.pippinCore,
            links: links,
            companyLink: companyLink,
            logicalParent: rootVC
        )
        infoVC.delegate = self

        let container = UIViewController()
        container.addChild(infoVC)
        container.view.addSubview(infoVC.view)
        infoVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoVC.view.topAnchor.constraint(equalTo: container.view.topAnchor),
            infoVC.view.bottomAnchor.constraint(equalTo: container.view.bottomAnchor),
            infoVC.view.leadingAnchor.constraint(equalTo: container.view.leadingAnchor),
            infoVC.view.trailingAnchor.constraint(equalTo: container.view.trailingAnchor),
        ])
        infoVC.didMove(toParent: container)

        if let userID = getUserID?() {
            userIDToCopy = userID
            containerView = container.view

            let titleLabel = UILabel()
            titleLabel.text = "User ID"
            titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            titleLabel.textColor = environment.colors.foreground.withAlphaComponent(0.5)
            titleLabel.textAlignment = .center

            let idLabel = UILabel()
            idLabel.text = userID
            idLabel.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
            idLabel.textColor = environment.colors.foreground.withAlphaComponent(0.7)
            idLabel.textAlignment = .center
            idLabel.numberOfLines = 0
            idLabel.lineBreakMode = .byCharWrapping

            let stack = UIStackView(arrangedSubviews: [titleLabel, idLabel])
            stack.axis = .vertical
            stack.spacing = 2
            stack.translatesAutoresizingMaskIntoConstraints = false
            container.view.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: container.view.centerXAnchor),
                stack.bottomAnchor.constraint(equalTo: container.view.bottomAnchor, constant: -20),
                stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.view.leadingAnchor, constant: 24),
                stack.trailingAnchor.constraint(lessThanOrEqualTo: container.view.trailingAnchor, constant: -24),
            ])

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(userIDLongPressed))
            stack.isUserInteractionEnabled = true
            stack.addGestureRecognizer(longPress)
        }

        let modal = DismissableModalViewController(
            childViewController: container,
            titleFont: environment.fonts.title,
            tintColor: environment.colors.foreground,
            imageBundle: Bundle.pippinCore,
            onClose: { [weak self] in self?.dismiss() }
        )

        let blur = BlurViewController(
            blurredViewController: modal,
            material: .systemUltraThinMaterial,
            vibrancyStyle: .label
        )

        let modalPresenter = TransparentModalPresentingViewController(childViewController: blur)
        self.modalPresenter = modalPresenter

        rootVC.addNewChildViewController(newChildViewController: modalPresenter)
        modalPresenter.view.fillSuperview()

        window.makeKeyAndVisible()
        modalPresenter.presentTransparently(animated: true)
    }

    public func dismiss() {
        modalPresenter?.dismissTransparently(animated: true) { [weak self] _ in
            self?.window?.isHidden = true
            self?.window = nil
            self?.modalPresenter = nil
            self?.containerView = nil
            self?.userIDToCopy = nil
        }
    }

    public func bugReportTapped(inInfoViewController infoViewController: InfoViewController) {
        environment.bugReporter?.show(
            fromViewController: infoViewController,
            screenshot: nil,
            metadata: nil
        )
    }
}

private extension InfoPresenter {
    @objc func userIDLongPressed(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let userID = userIDToCopy else { return }
        UIPasteboard.general.string = userID
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        guard let view = containerView else { return }
        showCopiedToast(in: view)
    }

    func showCopiedToast(in view: UIView) {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.72)
        container.layer.cornerRadius = 14
        container.layer.masksToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Copied to clipboard"
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])

        view.addSubview(container)
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -72),
        ])

        container.alpha = 0
        UIView.animate(withDuration: 0.2) {
            container.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5) {
                container.alpha = 0
            } completion: { _ in
                container.removeFromSuperview()
            }
        }
    }
}
#endif
