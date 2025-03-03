//
//  MoreDetail.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/3/25.
//

import Foundation
import UIKit

class MoreDetailsVC: UIViewController {
    
    private let moreText: String
    
    init(text: String) {
        self.moreText = text
        super.init(nibName: nil, bundle: nil)
        
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .white
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.textAlignment = .justified
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0) // Koyu arka plan
        view.backgroundColor = UIColor(red:0.176, green:0.176, blue:0.176, alpha:1.000)
        setupUI()
    }



    private func setupUI() {
        view.addSubview(textView)
        textView.text = moreText

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
        ])
    }

    @objc private func dismissView() {
        dismiss(animated: true)
    }
}
