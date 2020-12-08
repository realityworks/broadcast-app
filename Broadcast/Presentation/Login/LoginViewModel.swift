//
//  LoginViewModel.swift
//  Broadcast
//
//  Created by Piotr Suwara on 18/11/20.
//

import Foundation
import RxCocoa
import RxSwift

class LoginViewModel : ViewModel {
    private let authenticationUseCase: AuthenticationUseCase
    
    let username = BehaviorRelay<String?>(value: nil)
    let password = BehaviorRelay<String?>(value: nil)
    let isLoadingActivityVisible = BehaviorRelay<Bool>(value: false)
    let isLoginEnabled: Observable<Bool>
    
    init(dependencies: Dependencies = .standard) {
        self.authenticationUseCase = dependencies.authenticationUseCase
        
        isLoginEnabled = Observable.combineLatest(username, password) { username, password in
            guard let username = username,
                  let password = password else { return false }
            return !username.isEmpty && !password.isEmpty
        }
        
        super.init(stateController: dependencies.stateController)
    }
}

// MARK: - Dependencies

extension LoginViewModel {
    struct Dependencies {
        
        let stateController: StateController
        let authenticationUseCase: AuthenticationUseCase
        
        static let standard = Dependencies(
            stateController: Domain.standard.stateController,
            authenticationUseCase: Domain.standard.useCases.authenticationUseCase)
    }
}

// MARK: - Functions

extension LoginViewModel {
    func login() {
        stateController.state.authenticationState = AuthenticationState.loggingIn
        authenticationUseCase.login(username: username.value ?? "",
                                    password: password.value ?? "")
            .subscribe {
                self.stateController.state.authenticationState = AuthenticationState.loggedIn
            } onError: { _ in
                // TODO (Loading indicator update)
                self.stateController.state.authenticationState = AuthenticationState.loggedOut
            }
            .disposed(by: disposeBag)

    }
}
