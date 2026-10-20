//
//  ProgressVC.swift
//  FeasyMesh
//
//  Created by chenchanghua on 2022/8/16.
//

import UIKit
import FeasyMeshSDK

class ProgressVC: UIViewController {
    
    // MARK: - Properties
    
    internal var alert: UIAlertController?
    private var messageHandle: MessageHandle?
    
    // MARK: - Implementation
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        if #available(iOS 13.0, *) {
            if let presentationController = self.parent?.presentationController,
               let delegate = presentationController.delegate {
                delegate.presentationControllerDidDismiss?(presentationController)
            }
        }
    }
    
    /// Displays the progress alert with specified status message
    /// and calls the completion callback.
    ///
    /// - parameter message: Message to be displayed to the user.
    /// - parameter completion: A completion handler.
    func start(_ message: String, completion: @escaping () -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let alert = self.alert {
                alert.message = message
            } else {
                self.alert = UIAlertController(title: LS("Status"), message: message, preferredStyle: .alert)
                self.alert!.addAction(UIAlertAction(title: LS("Cancel"), style: .cancel) {
                    [weak self] _ in self?.alert = nil
                })
                self.present(self.alert!, animated: true)
            }
            
            completion()
        }
    }
    
    /// Displays the progress alert with specified status message
    /// and calls the completion callback.
    ///
    /// - parameter message: Message to be displayed to the user.
    /// - parameter completion: A completion handler.
    func start(_ message: String, completion: @escaping () throws -> MessageHandle?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            do {
                self.messageHandle = try completion()
                guard let _ = self.messageHandle else {
                    self.done()
                    return
                }

                if let alert = self.alert {
                    alert.message = message
                } else {
                    self.alert = UIAlertController(title: LS("Status"),
                                                   message: message,
                                                   preferredStyle: .alert)
                    self.alert!.addAction(UIAlertAction(title: LS("Cancel"), style: .cancel) { [weak self] _ in
                        self?.messageHandle?.cancel()
                        self?.alert = nil
                    })
                    self.present(self.alert!, animated: true)
                }
            } catch {
                self.messageHandle = nil
                let completion: () -> Void = {
                    // Refresh Control does not collapse with animation when
                    // an Alert Control is shown immediately afterwards.
                    
                    // A dirty hack to finish refreshing with animation.
                    // See: https://stackoverflow.com/a/50278729/2115352
                    // self.tableView.setContentOffset(CGPoint.zero, animated: true)
                    
                    self.alert = UIAlertController(title: LS("Error"),
                                                   message: error.localizedDescription,
                                                   preferredStyle: .alert)
                    self.alert!.addAction(UIAlertAction(title: LS("OK"), style: .cancel) { [weak self] _ in
                        self?.alert = nil
                    })
                    self.present(self.alert!, animated: true)
                }
                if let alert = self.alert {
                    alert.dismiss(animated: true, completion: completion)
                } else {
                    completion()
                }
            }
        }
    }
    
    /// This method dismisses the progress alert dialog.
    ///
    /// - parameter completion: An optional completion handler.
    func done(completion: (() -> Void)? = nil) {
        if let alert = alert {
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: completion)
            }
        } else {
            DispatchQueue.main.async {
                completion?()
            }
        }
        alert = nil
    }
    
    func clearAlert() {
        if let alert = alert {
            DispatchQueue.main.async {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        alert = nil
    }
    
}
