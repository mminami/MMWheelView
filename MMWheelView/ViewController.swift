//
//  ViewController.swift
//  MMWheelView
//
//  Created by mminami on 2017/12/09.
//  Copyright © 2017 mminami. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        return textField
    }()

    lazy var passworTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.white
        return textField
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        view.addSubview(nameTextField)
        view.addSubview(passworTextField)
        view.addSubview(loginButton)

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
            make.height.equalTo(30)
        }

        passworTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField).offset(50)
            make.width.height.equalTo(nameTextField)
            make.centerX.equalTo(nameTextField)
        }

        loginButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view).offset(-50)
            make.height.equalTo(44)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

