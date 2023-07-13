//
//  ContactEmailView.swift
//  coffice
//
//  Created by MinKyeongTae on 2023/07/14.
//  Copyright © 2023 kr.co.yapp. All rights reserved.
//

import SwiftUI
import MessageUI

// Credit for this struct goes to https://swiftuirecipes.com/blog/send-mail-in-swiftui
typealias MailViewCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

struct ContactEmailView: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  @Binding var contactEmailViewState: ContactEmailViewState
  let callback: MailViewCallback

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
    @Binding var presentation: PresentationMode
    @Binding var viewState: ContactEmailViewState
    let callback: MailViewCallback

    init(
      presentation: Binding<PresentationMode>,
      data: Binding<ContactEmailViewState>,
      callback: MailViewCallback
    ) {
      _presentation = presentation
      _viewState = data
      self.callback = callback
    }

    func mailComposeController(
      _ controller: MFMailComposeViewController,
      didFinishWith result: MFMailComposeResult,
      error: Error?
    ) {
      if let error {
        callback?(.failure(error))
      } else {
        callback?(.success(result))
      }
      $presentation.wrappedValue.dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(presentation: presentation, data: $contactEmailViewState, callback: callback)
  }

  func makeUIViewController(
    context: UIViewControllerRepresentableContext<ContactEmailView>
  ) -> MFMailComposeViewController {
    let viewController = MFMailComposeViewController()
    viewController.mailComposeDelegate = context.coordinator
    viewController.setSubject(contactEmailViewState.subject)
    viewController.setToRecipients([contactEmailViewState.toAddress])
    viewController.setMessageBody(contactEmailViewState.body, isHTML: false)
    if let emailData = contactEmailViewState.data {
      viewController.addAttachmentData(emailData, mimeType: "text/plain", fileName: "\(displayName).json")
    }
    viewController.accessibilityElementDidLoseFocus()
    return viewController
  }

  func updateUIViewController(
    _ uiViewController: MFMailComposeViewController,
    context: UIViewControllerRepresentableContext<ContactEmailView>
  ) {}

  static var canSendMail: Bool {
    MFMailComposeViewController.canSendMail()
  }
}

extension ContactEmailView {
  var displayName: String {
    CofficeResources.bundle.object(forInfoDictionaryKey: "CFBundleName")
    as? String ?? "Could not determine the application name"
  }
}
