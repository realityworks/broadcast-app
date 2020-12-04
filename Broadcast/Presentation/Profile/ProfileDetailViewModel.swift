//
//  ProfileDetailViewModel.swift
//  Broadcast
//
//  Created by Piotr Suwara on 3/12/20.
//

import Foundation
import RxSwift

class ProfileDetailViewModel : ViewModel {
    
    enum Row {
        case profileInfo
        case displayName
        case biography
        case trailerVideo
    }
    
    let profileUseCase: ProfileUseCase
    let displayName: Observable<String>
    let biography: Observable<String>
    let subscribers: Observable<Int>
    let thumbnail: Observable<URL?>
    
    init(dependencies: Dependencies = .standard) {
        
        self.profileUseCase = dependencies.profileUseCase
        
        let profileObservable = dependencies.profileObservable.compactMap { $0 }
        
        self.displayName = profileObservable.map { $0.displayName }
        self.biography = profileObservable.map { $0.biography }
        self.subscribers = profileObservable.map { $0.subscribers }
        self.thumbnail = profileObservable.map { URL(string: $0.thumbnailUrl) }
        
        super.init(stateController: dependencies.stateController)
    }
    
}

/// NewPostViewModel dependencies component
extension ProfileDetailViewModel {
    struct Dependencies {
        
        let stateController: StateController
        let profileUseCase: ProfileUseCase
        let profileObservable: Observable<Profile?>
        
        static let standard = Dependencies(
            stateController: Domain.standard.stateController,
            profileUseCase: Domain.standard.useCases.profileUseCase,
            profileObservable: Domain.standard.stateController.stateObservable(of: \.profile))
    }
}

