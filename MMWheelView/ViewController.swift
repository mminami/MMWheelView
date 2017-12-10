//
//  ViewController.swift
//  MMWheelView
//
//  Created by mminami on 2017/12/09.
//  Copyright © 2017 mminami. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

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
        button.isEnabled = false
        return button
    }()

    private let disposeBag = DisposeBag()

    private let minimumPasswordLength = 5

    private func isValidEmail(_ text: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        view.addSubview(nameTextField)
        view.addSubview(passworTextField)
        view.addSubview(loginButton)

        nameTextField.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
            make.height.equalTo(30)
        }

        passworTextField.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.nameTextField).offset(50)
            make.width.height.equalTo(self.nameTextField)
            make.centerX.equalTo(self.nameTextField)
        }

        loginButton.snp.makeConstraints { [unowned self] make in
            make.bottom.equalTo(self.view).offset(-50)
            make.height.equalTo(44)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }

        nameTextField.rx
            .controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] text in
                self.passworTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)

        let emailIsValid = nameTextField.rx.text.orEmpty.map { [unowned self] in
            self.isValidEmail($0)
            }.share(replay: 1)

        let passwordIsValid = passworTextField.rx.text.orEmpty.map { [unowned self] in
            $0.count > self.minimumPasswordLength
            }.share(replay: 1)

        let formIsValid = Observable.combineLatest(emailIsValid, passwordIsValid) {
            $0 && $1
            }.share(replay: 1)

        formIsValid.subscribe(onNext: { [unowned self] in
            self.loginButton.isEnabled = $0
            self.loginButton.backgroundColor = $0 ? .orange : .lightGray
        }).disposed(by: disposeBag)

        loginButton.rx.tap.subscribe(onNext: { [unowned self] in
            let vc = WheelViewController()
            let navigationVC = UINavigationController(rootViewController: vc)
            self.present(navigationVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

