//
//  StandardAPIService.swift
//  Broadcast
//
//  Created by Piotr Suwara on 18/11/20.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire

typealias APIParameters = Dictionary<String, String>

class StandardAPIService {
    let baseUrl: URL
    let session: Session
    let schedulers: Schedulers
    
    init(dependencies: Dependencies = .standard) {
        self.baseUrl = dependencies.baseUrl
        self.schedulers = dependencies.schedulers
        self.session = Session.default
    }
    
    private func request(method: HTTPMethod,
                         url: URL,
                         parameters: APIParameters,
                         encoding: ParameterEncoding = URLEncoding.httpBody) -> Single<(HTTPURLResponse, Data)> {

        return session.rx
            .request(urlRequest: URLAPIQueryStringRequest(method, url, parameters: parameters))
            .observeOn(Schedulers.standard.main)
            .responseData()
            .asSingle()
    }
    
    private func authenticatedRequest(method: HTTPMethod,
                                      url: URL,
                                      parameters: APIParameters,
                                      encoding: ParameterEncoding = URLEncoding.httpBody) -> Single<(HTTPURLResponse, Data)> {
        return session.rx
            .request(urlRequest: URLAPIQueryStringRequest(method, url, parameters: parameters))
            .observeOn(Schedulers.standard.main)
            .responseData()
            .asSingle()
    }
}

extension StandardAPIService : APIService {
    func loadMyPosts() -> Single<LoadMyPostsResponse> {
        let single = Single<LoadMyPostsResponse>.create { observer in
            observer(.error(BoomdayError.unsupported))
            return Disposables.create { }
        }
        return single
    }
    
    func loadProfile() -> Single<LoadProfileResponse> {
        let single = Single<LoadProfileResponse>.create { observer in
            observer(.error(BoomdayError.unsupported))
            return Disposables.create { }
        }
        return single
    }
    
    func updateProfile(withDisplayName displayName: String, biography: String) -> Completable {
        return Completable.empty()
    }
    
    func uploadProfileImage(withData: Data) -> Completable {
        return Completable.empty()
    }
    
    func create(newPost: NewPost) -> Completable {
        return Completable.empty()
    }
}

extension StandardAPIService : AuthenticationService {
    func authenticate(withUsername username: String, password: String) -> Single<AuthenticateResponse> {
        let url = baseUrl
            .appendingPathComponent("connect")
            .appendingPathComponent("account")
        
        let parameters = ["username": username,
                          "password": password,
                          "grant_type": "password",
                          "scope": "offline_access",]
        
        return request(method: .post, url: url, parameters: parameters)
            .decode(type: AuthenticateResponse.self)
    }
    
    func refresh(token: String) -> Single<AuthenticateResponse> {
        let single = Single<AuthenticateResponse>.create { observer in
            observer(.success(AuthenticateResponse(authenticationToken: "", refreshToken: "")))
            return Disposables.create { }
        }
        return single
    }
}

// MARK: - Instance

extension StandardAPIService {
    
    static let standard = {
        StandardAPIService()
    }()
    
    struct Dependencies {
        
        let schedulers: Schedulers
        let baseUrl: URL
        
        static let standard = Dependencies(
            schedulers: Schedulers.standard,
            baseUrl: Configuration.apiServiceURL)
    }
}
