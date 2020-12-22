//
//  LoginViewController.swift
//  Broadcast
//
//  Created by Piotr Suwara on 18/11/20.
//

import UIKit
import TinyConstraints
import RxCocoa
import RxSwift
import SwiftRichString

class LoginViewController: ViewController, KeyboardEventsAdapter {
    var dismissKeyboardGestureRecognizer: UIGestureRecognizer = UITapGestureRecognizer()
    
    private let viewModel = LoginViewModel()
    
    // MARK: UI Components
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let bottomStackView = UIStackView()
    private let logoImageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView()
    
    private let usernameTextField = UITextField.standard(
        withPlaceholder: LocalizedString.usernamePlaceholder)
    
    private let passwordTextField = UITextField.password(
        withPlaceholder: LocalizedString.passwordPlaceholder)
    
    private let errorDisplayView = DismissableLabel()
    private let loginButton = UIButton.standard(
        withTitle: LocalizedString.loginButton)
    
    private let applyHereTextView = UITextView()
    private let termsAndConditionsTextView = UITextView()
    private let forgotPasswordTextView = UITextView()
    
    private let testUserName: String = "Pink67@gmail.com"
    private let testPassword: String = "Pass123$"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureViews()
        configureLayout()
        configureBindings()
        style()
        registerForKeyboardEvents()
    }
    
    /// Setup the UI component layout
    private func configureViews() {
        view.addGestureRecognizer(dismissKeyboardGestureRecognizer)
        dismissKeyboardGestureRecognizer.addTarget(self, action: #selector(dismissKeyboard))
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.distribution = .equalSpacing
        contentStackView.spacing = 16
        
        applyHereTextView.isScrollEnabled = false
        
        activityIndicator.hidesWhenStopped = true
        
        bottomStackView.axis = .horizontal
        bottomStackView.alignment = .center
        bottomStackView.distribution = .fillEqually
        
        if Configuration.debugUIEnabled {
            usernameTextField.text = testUserName
            passwordTextField.text = testPassword
            viewModel.username.accept(testUserName)
            viewModel.password.accept(testPassword)
        }
    }
    
    private func configureLayout() {
        view.addSubview(scrollView)
        
        /// Setup scroll view
        scrollView.edgesToSuperview(usingSafeArea: true)
        scrollView.addSubview(contentStackView)
        scrollView.addSubview(activityIndicator)
        
        /// Setup content stack view
        contentStackView.topToSuperview()
        contentStackView.widthToSuperview(offset: 24)
        contentStackView.addArrangedSubview(logoImageView)
        
        /// Add arranged views to stack
        contentStackView.addSpace(300)
        contentStackView.addArrangedSubview(usernameTextField)
        contentStackView.addArrangedSubview(passwordTextField)
        contentStackView.addArrangedSubview(errorDisplayView)
        contentStackView.addArrangedSubview(loginButton)
        contentStackView.addArrangedSubview(applyHereTextView)
        
        activityIndicator.centerY(to: loginButton)
        activityIndicator.leftToRight(of: loginButton)
        
        /// Configure insets of arranged sub views
        let textFields = [usernameTextField, passwordTextField]
        textFields.forEach {
            $0.widthToSuperview()
        }
        
        loginButton.widthToSuperview()
        
        /// Configure the bottom stackview
        view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(forgotPasswordTextView)
        bottomStackView.addArrangedSubview(termsAndConditionsTextView)
        bottomStackView.bottomToSuperview(offset: -8, usingSafeArea: true)
        bottomStackView.widthToSuperview()
        
        /// Configure the text views
        
        applyHereTextView.height(30)
        applyHereTextView.leftToSuperview()
        applyHereTextView.rightToSuperview()
        
        forgotPasswordTextView.height(30)
        termsAndConditionsTextView.height(30)
    }
    
    /// Configure the bindings between the view model and
    private func configureBindings() {
        
        usernameTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] _ in
                self.passwordTextField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent([.editingDidEndOnExit])
            .subscribe(onNext: { [unowned self] _ in
                self.passwordTextField.resignFirstResponder()
                self.viewModel.login()
            })
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                self.dismissKeyboard()
                self.viewModel.login()
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoginEnabled
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        usernameTextField.rx.controlEvent(.editingChanged)
            .map { [unowned self] in self.usernameTextField.text }
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.controlEvent(.editingChanged)
            .map { [unowned self] in self.passwordTextField.text }
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    /// Style the user interface and components
    private func style() {
        view.backgroundColor = .white
        
        // Style attributed strings
        let boomdayLinkStyle = Style {
            $0.font = UIFont.titleBold
            $0.underline = (.single, UIColor.black)
            $0.linkURL = URL(string: "https://boomday.com")
            $0.alignment = .center
        }
        
        applyHereTextView.attributedText =
            "\(LocalizedString.notABroadcaster.localized) ".set(style: Style.titleCenter) +
            LocalizedString.learnMore.localized.set(style: boomdayLinkStyle)
        
        let forgotPasswordStyle = Style {
            $0.font = UIFont.title
            $0.alignment = .center
            $0.linkURL = URL(string: "https://boomday.com")
        }
        
        forgotPasswordTextView.attributedText = "Forgot your password?".set(style: forgotPasswordStyle)
                
        let termsAndConditionsStyle = Style {
            $0.font = UIFont.title
            $0.alignment = .center
            $0.linkURL = URL(string: "https://boomday.com")
        }
        
        termsAndConditionsTextView.attributedText = "Terms and Conditions".set(style: termsAndConditionsStyle)

        // Style the text views
        let textViews = [applyHereTextView,
                         forgotPasswordTextView,
                         termsAndConditionsTextView]
        
        textViews.forEach { $0.tintColor = .black }
        
        // Setup the left view for the login/password views
        
    }
    
    @objc func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

