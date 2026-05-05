#if canImport(UIKit)
import Foundation

@MainActor
final class BugReportViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var message: String = ""

    private let onSubmit: (String, String?, String?) -> Void

    init(onSubmit: @escaping (String, String?, String?) -> Void) {
        self.onSubmit = onSubmit
    }

    var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func submit() {
        guard canSubmit else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        onSubmit(
            message.trimmingCharacters(in: .whitespaces),
            trimmedName.isEmpty ? nil : trimmedName,
            trimmedEmail.isEmpty ? nil : trimmedEmail
        )
    }
}
#endif
