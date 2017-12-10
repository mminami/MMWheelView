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
import SVProgressHUD

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()

    private let minimumPasswordLength = 5
    private let emailValidationText = "Enter valid email address"
    private var passwordValidationText: String {
        return "Minimum password length is \(minimumPasswordLength)"
    }

    private let progressDismissTimeinterval = 1.0

    lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()

    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.becomeFirstResponder()
        textField.placeholder = "Enter email"
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    lazy var emailValidationLabel: UILabel = {
        let label = UILabel()
        label.text = emailValidationText
        label.textColor = .red
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()

    lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.textColor = .white
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()

    lazy var passworTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter password"
        textField.backgroundColor = UIColor.white
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()

    lazy var passwordValidationLabel: UILabel = {
        let label = UILabel()
        label.text = passwordValidationText
        label.textColor = .red
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()

    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.isEnabled = false
        return button
    }()

    private func isValidEmail(_ text: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: text)
    }

    private func setUpUI() {
        navigationItem.title = "Login"

        view.backgroundColor = .black

        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(emailValidationLabel)
        view.addSubview(passwordLabel)
        view.addSubview(passworTextField)
        view.addSubview(passwordValidationLabel)
        view.addSubview(loginButton)

        emailLabel.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.equalTo(self.view).offset(70)
            make.right.equalTo(self.view).offset(-70)
            make.height.equalTo(30)
        }

        emailTextField.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.emailLabel.snp.bottom).offset(4)
            make.left.equalTo(self.view).offset(70)
            make.right.equalTo(self.view).offset(-70)
            make.height.equalTo(30)
        }

        emailValidationLabel.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(2)
            make.left.equalTo(self.emailTextField.snp.left)
            make.right.equalTo(self.emailTextField.snp.right)
            make.height.equalTo(self.emailTextField.snp.height)
        }

        passwordLabel.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.emailValidationLabel.snp.bottom).offset(4)
            make.left.equalTo(self.emailLabel.snp.left)
            make.right.equalTo(self.emailLabel.snp.right)
            make.height.equalTo(self.emailLabel.snp.height)
        }

        passworTextField.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.passwordLabel.snp.bottom).offset(4)
            make.width.equalTo(self.emailTextField.snp.width)
            make.height.equalTo(self.emailTextField.snp.height)
            make.centerX.equalTo(self.emailTextField.snp.centerX)
        }

        passwordValidationLabel.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.passworTextField.snp.bottom).offset(2)
            make.left.equalTo(self.emailValidationLabel.snp.left)
            make.right.equalTo(self.emailValidationLabel.snp.right)
            make.height.equalTo(self.emailValidationLabel.snp.height)
        }

        loginButton.snp.makeConstraints { [unowned self] make in
            make.top.equalTo(self.passwordValidationLabel.snp.bottom).offset(15)
            make.height.equalTo(44)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
    }

    private func setUpDeclaration() {
        let emailIsValid = emailTextField.rx.text.orEmpty.map { [unowned self] in
            self.isValidEmail($0)
            }.share(replay: 1)

        let passwordIsValid = passworTextField.rx.text.orEmpty.map { [unowned self] in
            $0.count >= self.minimumPasswordLength
            }.share(replay: 1)

        let formIsValid = Observable.combineLatest(emailIsValid, passwordIsValid) {
            $0 && $1
            }.share(replay: 1)

        emailIsValid
            .bind(to: emailValidationLabel.rx.isHidden)
            .disposed(by: disposeBag)

        passwordIsValid
            .bind(to: passwordValidationLabel.rx.isHidden)
            .disposed(by: disposeBag)

        formIsValid.subscribe(onNext: { [unowned self] in
            self.loginButton.isEnabled = $0
            self.loginButton.backgroundColor = $0 ? .orange : .lightGray
        }).disposed(by: disposeBag)

        emailTextField.rx
            .controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] text in
                self.passworTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)

        loginButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                self.emailTextField.resignFirstResponder()
                self.passworTextField.resignFirstResponder()

                DispatchQueue.main.async {
                    SVProgressHUD.setDefaultMaskType(.gradient)
                    SVProgressHUD.setMinimumDismissTimeInterval(self.progressDismissTimeinterval)
                    SVProgressHUD.show()
                }

                // Delay process to show loading indicator
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    MockLoginClient.shared.login(
                        email: self.emailTextField.text ?? "",
                        password: self.passworTextField.text ?? "",
                        completion: { [unowned self] result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    SVProgressHUD.showSuccess(withStatus: "Success to authenticate")

                                    DispatchQueue.main.asyncAfter(deadline: .now() + self.progressDismissTimeinterval) {
                                        SVProgressHUD.dismiss()

                                        let vc = WheelViewController()
                                        let navigationVC = UINavigationController(rootViewController: vc)
                                        navigationVC.navigationBar.barStyle = .black
                                        navigationVC.navigationBar.isTranslucent = true
                                        self.present(navigationVC, animated: true, completion: nil)
                                    }
                                }
                            case .failure:
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    SVProgressHUD.showError(withStatus: "Failed to authenticate")
                                }
                            }
                    })
                }
        }).disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()

        setUpDeclaration()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

