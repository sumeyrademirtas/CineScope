//
//  ProgressBar.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 2/7/25.
//

import Foundation
import UIKit
import Lottie
public class ProgressBar: UIView {
    
    private var progress: LottieAnimationView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: .zero)
        setUpInit()
    }
    

    
    func loading(isShow: Bool){
        if isShow{
            progress.play()
        }else{
            progress.stop()
        }
    }
    
    private func setUpInit() {
        progress = LottieAnimationView()
        progress.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(progress)
        NSLayoutConstraint.activate([
            
            progress.heightAnchor.constraint(equalToConstant: 200),
            progress.widthAnchor.constraint(equalToConstant: 200),
            progress.centerXAnchor.constraint(equalTo: centerXAnchor),
            progress.centerYAnchor.constraint(equalTo: centerYAnchor)

            ])
        
        progress.animation = LottieAnimation.named("progress")
                 progress.loopMode = .loop
    }

}
