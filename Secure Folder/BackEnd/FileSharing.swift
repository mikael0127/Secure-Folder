//
//  FileSharing.swift
//  Secure Folder
//
//  Created by Bryan Loh on 28/07/2023.
//

import UIKit
import MessageUI

class FileSharing: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    private override init() { super.init() }
    static let shared = FileSharing()
    
    func share(_ items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        activityVC.popoverPresentationController?.sourceView = rootViewController.view
        rootViewController.present(activityVC, animated: true)
    }
    
    func message(_ images: [UIImage]) {
        guard MFMessageComposeViewController.canSendText() else { return print("device can't send messages") }
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        images.compactMap { $0.pngData() }.forEach { imageData in
            messageVC.addAttachmentData(imageData, typeIdentifier: "public.data", filename: "image.png")
        }
        rootViewController.present(messageVC, animated: true)
    }
    
    func message(_ items: [URL]) {
        guard MFMessageComposeViewController.canSendText() else { return print("device can't send messages") }
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        let messageVC = MFMessageComposeViewController()
        messageVC.messageComposeDelegate = self
        items.compactMap { try? (Data(contentsOf: $0), $0.lastPathComponent) }.forEach { docData, name in
            messageVC.addAttachmentData(docData, typeIdentifier: "public.data", filename: name)
        }
        rootViewController.present(messageVC, animated: true)
    }
        
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
    
}
