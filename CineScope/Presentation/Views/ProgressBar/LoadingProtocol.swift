//
//  LoadingProtocol.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/7/25.
//

import Foundation
import UIKit

public protocol LoadingProtocol {
    var animator: ProgressBar { get }
    func loading(isShow: Bool)
}

public extension LoadingProtocol where Self: UIViewController {
    func loading(isShow: Bool) {
        if isShow {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let window = UIApplication.shared.getKeyWindow() {
                    self.animator.frame = window.bounds
                    window.addSubview(self.animator)
                    self.animator.loading(isShow: isShow)
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.animator.loading(isShow: isShow)
                self?.animator.removeFromSuperview()
            }
        }
    }
}

extension UIApplication {
    func getKeyWindow() -> UIWindow? {
        // Find the first UIWindowScene from connected scenes
        if let windowScene = connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            // Return the key window of the scene
            return windowScene.windows.first(where: { $0.isKeyWindow })
        }
        return nil
    }
}
