#if canImport(UIKit)
import SwiftUI

struct BugReportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel: BugReportViewModel

    init(viewModel: BugReportViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Your info (optional)") {
                    TextField("Name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("What went wrong?") {
                    TextEditor(text: $viewModel.message)
                        .frame(minHeight: 120)
                        .accessibilityLabel("What went wrong?")
                        .overlay(alignment: .topLeading) {
                            if viewModel.message.isEmpty {
                                Text("Describe what happened…")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                                    .allowsHitTesting(false)
                                    .accessibilityHidden(true)
                            }
                        }
                }
            }
            .navigationTitle("Report a Bug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        viewModel.submit()
                        dismiss()
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
        }
    }
}
#endif
