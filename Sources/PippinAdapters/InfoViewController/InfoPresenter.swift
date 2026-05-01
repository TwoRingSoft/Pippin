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

    private let environment: Pippin.Environment
    private let acknowledgements: Acknowledgements
    private let contactEmails: [String]
    private let links: [LinkIcon]
    private let companyLink: LinkIcon

    public init(
        environment: Pippin.Environment,
        acknowledgements: Acknowledgements,
        contactEmails: [String],
        links: [LinkIcon] = [],
        companyLink: LinkIcon
    ) {
        self.environment = environment
        self.acknowledgements = acknowledgements
        self.contactEmails = contactEmails
        self.links = links
        self.companyLink = companyLink
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
#endif
