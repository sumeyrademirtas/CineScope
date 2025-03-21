//
//  SplashViewController.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/19/25.
//

import Lottie
import UIKit

class SplashViewController: UIViewController {
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView(name: "splashlottie") // JSON dosyanın adı
        view.contentMode = .scaleAspectFill // Tam ekran yapacak
        view.loopMode = .playOnce
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let splashTextLabel: UILabel = {
        let label = UILabel()
        label.text = "CineScope"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        // Arka plan rengi: #21222d
        label.backgroundColor = UIColor(red: 33/255.0, green: 34/255.0, blue: 45/255.0, alpha: 1)
        label.alpha = 0 // Başlangıçta gizli
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true // Corner radius'un görünmesi için
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black // Splash için arka plan rengi
        setupAnimation()
        setupLabel()
    }
    
    private func setupAnimation() {
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        animationView.play { [weak self] finished in
            if finished {
                self?.navigateToMainScreen()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            UIView.animate(withDuration: 1.0) {
                self?.splashTextLabel.alpha = 1.0
            }
        }
    }
    
    private func setupLabel() {
        view.addSubview(splashTextLabel)
        
        NSLayoutConstraint.activate([
            splashTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30),
            splashTextLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashTextLabel.widthAnchor.constraint(equalToConstant: 200),
            splashTextLabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func navigateToMainScreen() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let mainVC = MainTabBarController()
            mainVC.modalPresentationStyle = .fullScreen
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = mainVC
            }, completion: nil)
        }
    }
}
